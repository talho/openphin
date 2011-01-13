class Admin::InvitationsController < ApplicationController
  
  require 'fastercsv'
  before_filter :admin_required
  before_filter :force_json_as_html, :only => :import
  app_toolbar "admin"

  def index
    @invitations = Invitation.all

    respond_to do |format|
      format.html
      format.json do
        render :json => {:success => true, :invitations => @invitations.map{|i| {:name => i.name, :id => i.id}}}.as_json
      end
    end
  end
  
  def show
    @invitation = Invitation.find(params[:id])
    
    respond_to do |format|
      format.html
      format.json do
        options = {}
        params[:reverse] = (params[:dir] && params[:dir] == 'DESC') ? "1" : nil
        if params[:sort]
          case params[:sort]
            when 'email'
              options[:order] = 'invitees.email'
            when 'name'
              options[:order] = 'invitees.name'
            else
              options[:order] = 'invitees.name'
          end
          if params[:dir] && params[:dir] == 'ASC'
            options[:order] += ' ASC'
          else
            options[:order] += ' DESC'
          end
        end
        
        options[:per_page] = params[:per_page] = (params[:limit] || 20).to_i
        options[:page] = params[:page] = (params[:start].to_i / params[:limit].to_i) + 1
        invitees = case params[:sort]
          when 'completionStatus'
            inviteeStatus
          when 'pendingRequests'
            inviteeStatusByPendingRequests
          when 'organizationMembership'
            @invitation.default_organization ? inviteeStatusByOrganization : @invitation.invitees.paginate(options)
          when 'profileUpdated'
            inviteeStatusByProfileUpdate
          else
            @invitation.invitees.paginate(options)
        end.map{|i| {
          :name => i.name,
          :email => i.email,
          :completionStatus => i.completion_status,
          :organizationMembership => @invitation.default_organization ? i.is_member? : 'N/A',
          :profileUpdated => i.user && i.user.updated_at > @invitation.created_at ? "Yes" : "No",
          :pendingRequests => i.user ? i.user.role_requests.unapproved.map do |rr|
             if current_user.is_admin_for?(rr.jurisdiction)
               {
                 :role => rr.role.name,
                 :jurisdiction => rr.jurisdiction.name,
                 :approve_url => "#{url_for(:controller => 'admin/role_requests', :action => 'approve', :id => rr.id, :only_path => true)}.json",
                 :deny_url => "#{url_for(:controller => 'admin/role_requests', :action => 'deny', :id => rr.id, :only_path => true)}.json"
               }
             else
               nil
             end
            end.compact : []
        }}

        render :json => {
          :success => true,
          :invitation => {
            :name => @invitation.name,
            :id => @invitation.id,
            :subject => h(@invitation.subject),
            :body => @invitation.body,
            :organization => @invitation.default_organization ? @invitation.default_organization.name : nil,
            :complete_percentage => @invitation.registrations_complete_percentage,
            :incomplete_percentage => @invitation.registrations_incomplete_percentage,
            :complete_total => @invitation.registrations_complete_total,
            :incomplete_total => @invitation.registrations_incomplete_total
          },                                                                               
          :total => @invitation.invitees.size,
          :invitees => invitees
        }.as_json
      end
    end
  end
  
  def new
    @invitation = Invitation.new
  end

  def import
    invitees = []
    csvfile = params[:invitation][:csvfile]
    newfile = File.join(Rails.root,'tmp',csvfile.original_filename)
    File.open(newfile,'wb') do |file|
      file.puts csvfile.read
    end
    error = nil

    begin
      FasterCSV.open(newfile, :col_sep => ",", :headers => true) do |records|
        records.each do |record|
          invitees.push({:name => record["name"].delete(","), :email => record["email"]})
        end
      end
    rescue FasterCSV::MalformedCSVError => detail
      error = "CSV file was malformed or corrupted.<br/><br/>Error:<br/>#{detail.message}"
    rescue
      error = "This does not appear to be a CSV file."
    end

    respond_to do |format|
      format.html do
        if error.nil?
          render :json => {:success => true, :invitees_attributes => invitees}.as_json, :content_type => 'text/html'
        else
          render :json => {:success => false, :error => error}.as_json, :content_type => 'text/html'
        end
      end

      format.json do
        if error.nil?
           render :json => {:success => true, :invitees_attributes => invitees}.as_json
         else
           render :json => {:success => false, :error => error}.as_json
         end
       end
    end
  end
  
  def create
    paramsWithCSVInvitees unless params[:invitation][:csvfile].blank?
    params[:invitation].delete("csvfile")
    params[:invitation][:author_id] = current_user.id

    addSignupLinkToBody

    @invitation = Invitation.new(params[:invitation])
    if @invitation.save
      respond_to do |format|
        format.html do
          if @invitation.deliver
            flash[:notice] = "Invitation was successfully sent."
          else
            flash[:notice] = "Invitation was created but did not send."
          end
          redirect_to admin_invitation_path(@invitation)
        end

        format.json do
          if @invitation.deliver
            render :json => {:success => true, :flash => 'Invitation was successfully sent'}.as_json
          else
            render :json => {:success => false, :error => 'Invitation was created but did not send'}.as_json
          end
        end
      end
    end
  end

  def reports
    invitation = Invitation.find(params[:id])
    report_options = [["By Email","by_email"], ["By Registrations","by_registrations"]]
    report_options << ["By Organization","by_organization"] unless invitation.default_organization.nil?
    report_options << ["By Pending Requests","by_pendingRequests"]
    report_options << ["By Profile Update","by_profileUpdated"]

    @reverse = params[:reverse] == "1" ? nil : "1"

    @csv_options = { :col_sep => ',', :row_sep => :auto }
    @output_encoding = 'LATIN1'
    @timestamp = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    respond_to do |format|
      
      case params[:report_type]
      when "by_profileUpdated"
        results = inviteeStatusByProfileUpdate
        format.html do
          render :partial => "report_#{params[:report_type]}", 
                 :locals => {:results => results, :report_type => params[:report_type],
                   :invitation => invitation, :report_options => report_options}, 
                 :layout => "application"
        end
        format.pdf do
          render :partial => "report_#{params[:report_type]}", 
                 :locals => {:results => results, :invitation => invitation}
        end
        format.csv do
          @filename = "org_rpt_by_profile_update_#{@timestamp}.csv"
          render :partial => "report_#{params[:report_type]}", 
                 :locals => {:results => results, :invitation => invitation}
        end
        when "by_registrations"
          results = inviteeStatus
          format.html do
            render :partial => "report_#{params[:report_type]}", 
                   :locals => {:results => results, :report_type => params[:report_type],
                     :invitation => invitation, :report_options => report_options}, 
                   :layout => "application"
          end
          format.pdf do
            render :partial => "report_#{params[:report_type]}", 
                   :locals => {:results => results, :invitation => invitation}
          end
          format.csv do
            @filename = "org_rpt_by_registration_#{@timestamp}.csv"
            render :partial => "report_#{params[:report_type]}", 
                   :locals => {:results => results, :invitation => invitation}
          end
        when "by_organization"
          results = inviteeStatusByOrganization
          format.html do
            render :partial => "report_#{params[:report_type]}", 
                   :locals => {:results => results, :report_type => params[:report_type],
                     :invitation => invitation, :report_options => report_options}, 
                   :layout => "application"
          end
          format.pdf do
            render :partial => "report_#{params[:report_type]}", 
                   :locals => {:results => results, :invitation => invitation}
          end
          format.csv do
            @filename = "org_rpt_by_organization_#{@timestamp}.csv"
            render :partial => "report_#{params[:report_type]}", 
                   :locals => {:results => results, :invitation => invitation}
          end
        when "by_pendingRequests"
          results = inviteeStatusByPendingRequests
          format.html do
            render :partial => "report_#{params[:report_type]}", 
                   :locals => {:results => results, :report_type => params[:report_type],
                     :invitation => invitation, :report_options => report_options}, 
                   :layout => "application"
          end
          format.pdf do
            render :partial => "report_#{params[:report_type]}", 
                   :locals => {:results => results, :invitation => invitation}
          end
          format.csv do
            @filename = "org_rpt_by_pending_request_#{@timestamp}.csv"
            render :partial => "report_#{params[:report_type]}", 
                   :locals => {:results => results, :invitation => invitation}
          end
        else # Also by email
          options = {}
          case params[:sort]
            when 'email'
              options[:order] = 'invitees.email'
            when 'name'
              options[:order] = 'invitees.name'
            else
              options[:order] = 'invitees.name'
          end
          if params[:reverse]
            options[:order] += ' DESC'
          else
            options[:order] += ' ASC'
          end

          options[:per_page] = params[:per_page] || 20
          options[:page] = params[:page] || 1

          results = invitation.invitees.paginate(options)

          format.html do
            render :partial => "report_by_email", 
                   :locals => {:results => results, :report_type => params[:report_type],
                     :invitation => invitation, :report_options => report_options}, 
                   :layout => "application"
          end
          format.pdf do
            render :partial => "report_by_email", 
                   :locals => {:results => results, :invitation => invitation}
          end
          format.csv do
            @filename = "org_rpt_by_email_#{@timestamp}.csv"
            render :partial => "report_by_email", 
                   :locals => {:results => results, :invitation => invitation}
          end
        end
    end

  end

  def destroy
  end

  private
  def paramsWithCSVInvitees
    csvfile = params[:invitation][:csvfile]
    newfile = File.join(Rails.root,'tmp',csvfile.original_filename)
    File.open(newfile,'wb') do |file|
      file.puts csvfile.read
    end
    next_index = 0

    params[:invitation][:invitees_attributes].each do |key, value|
      next_index = key.to_i + 1 if key.to_i >= next_index
    end unless params[:invitation][:invitees_attributes].blank?

     begin
       lineno = 2
      FasterCSV.open(newfile, :col_sep => ",", :headers => true, :skip_blanks => true, :header_converters => :symbol) do |records|
        records.each do |record|
          params[:invitation][:invitees_attributes] = [] if params[:invitation][:invitees_attributes].blank?
          params[:invitation][:invitees_attributes]["#{next_index}"] = {}
          params[:invitation][:invitees_attributes]["#{next_index}"][:name] = record[:name].delete(",")
          params[:invitation][:invitees_attributes]["#{next_index}"][:email] = record[:email]
          next_index += 1
          lineno += 1
        end
      end
      return true
     rescue Exception => e
       flash[:error] = "Invitees CSV import failed on line #{lineno} with: " + e
       return false
     end
  end

  def addSignupLinkToBody
    if params[:invitation][:organization_id] && params[:invitation][:organization_id] != "Select an Organization..."
      link = "\n\n" + new_user_url + "?organization=" + params[:invitation][:organization_id]
      params[:invitation][:body] = params[:invitation][:body] + link
    end
  end

  def inviteeStatus
    order_in = params[:reverse] == '1' ? 'DESC' : 'ASC'
    order_by = params[:sort] != nil && params[:sort] != 'completionStatus' ? params[:sort] : 'email'
    Invitee.paginate_all_by_invitation_id params[:id], :select => "DISTINCT `invitees`.*", 
                                          :joins => "LEFT JOIN users ON `invitees`.email = `users`.email",
                                          :order => "`users`.email_confirmed #{order_in}, `invitees`.#{order_by} #{order_in}", :page => params[:page], :per_page => params[:per_page]
  end
  
  def inviteeStatusByOrganization
    order_in = params[:reverse] == '1' ? 'DESC' : 'ASC'
    order_by = params[:sort] != nil && params[:sort] != 'organizationMembership' ? params[:sort] : 'email'
    Invitee.paginate_all_by_invitation_id params[:id], :select => "DISTINCT `invitees`.*",
                                          :joins => "LEFT JOIN users ON `invitees`.email = `users`.email LEFT JOIN (audiences_users INNER JOIN audiences) ON (`users`.id = `audiences_users`.user_id AND `audiences_users`.audience_id = `audiences`.id AND `audiences`.scope='Organization')",
                                          :order => "`audiences`.id #{order_in == 'ASC' ? 'DESC' : 'ASC'}, `invitees`.#{order_by} #{order_in}", :page => params[:page], :per_page => params[:per_page]
  end

  def inviteeStatusByPendingRequests
    order_in = params[:reverse] == '1' ? 'DESC' : 'ASC'
    order_by = params[:sort] != nil && params[:sort] != 'pendingRequests' ? params[:sort] : 'email'
    Invitee.paginate_all_by_invitation_id params[:id], :select => "DISTINCT `invitees`.*",
                                         :joins => "LEFT JOIN users ON `invitees`.email = `users`.email LEFT JOIN role_requests ON `users`.id = `role_requests`.user_id AND `role_requests`.jurisdiction_id IN (#{current_user.role_memberships.admin_roles.map(&:jurisdiction_id).join(',')})",
                                         :order => "`role_requests`.id IS#{order_in == 'DESC' ? ' NOT ' : ' '}NULL, `invitees`.#{order_by} #{order_in}", :page => params[:page], :per_page => params[:per_page]
  end

  def inviteeStatusByProfileUpdate
    order_in = params[:reverse] == '1' ? 'DESC' : 'ASC'
    order_by = params[:sort] != nil && params[:sort] != 'profileUpdated' ? params[:sort] : 'email'
    order_by = "display_name" if order_by == "name"
    invitation_time = Invitation.find(params[:id]).updated_at
    Invitee.paginate_by_invitation_id params[:id], :select => "DISTINCT `invitees`.*", :joins => "LEFT JOIN users ON `invitees`.email = `users`.email",
                                      :order => "`users`.updated_at > '#{invitation_time}' #{order_in == 'ASC' ? 'DESC' : 'ASC'}, `invitees`.#{order_by} #{order_in}", :page => params[:page], :per_page => params[:per_page]
  end
  
  def csv_download
    send_file Rails.root.join("tmp","invitee.csv"), :type=>"application/xls" 
  end
end
