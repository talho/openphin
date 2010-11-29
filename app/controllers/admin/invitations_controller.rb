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
        params[:reverse] = (params[:dir] && params[:dir] == 'ASC') ? "1" : nil
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
        
        options[:per_page] = params[:per_page] = params[:limit] || 20
        options[:page] = params[:page] = (params[:start].to_i / params[:limit].to_i) + 1
        invitees = case params[:sort]
          when 'completionStatus'
            inviteeStatus
          when 'pendingRequests'
            options[:select] = "DISTINCT `invitees`.*"
            options[:order] = "`role_requests`.jurisdiction_id"
            options[:joins] = "LEFT JOIN users ON `invitees`.email = `users`.email LEFT JOIN role_requests ON `users`.id = `role_requests`.user_id" #[:user => :role_requests]
            @invitation.invitees.paginate(options)
            #inviteeStatusByPendingRequests
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
          :organizationMembership => 'N/A',
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
            :organization => @invitation.default_organization ? @invitation.default_organization.name : nil
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
    report_options << ["By Pending Requests","by_pending_requests"]
    report_options << ["By Profile Update","by_profile_update"]

    @reverse = params[:reverse] == "1" ? nil : "1"

    @csv_options = { :col_sep => ',', :row_sep => :auto }
    @output_encoding = 'LATIN1'
    @timestamp = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    respond_to do |format|
      
      case params[:report_type]
      when "by_profile_update"
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
        when "by_pending_requests"
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
          results = inviteeStatus
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
    FasterCSV.open(newfile, :col_sep => ",", :headers => true) do |records|
      records.each do |record|
        params[:invitation][:invitees_attributes] = [] if params[:invitation][:invitees_attributes].blank?
        params[:invitation][:invitees_attributes]["#{next_index}"] = {}
        params[:invitation][:invitees_attributes]["#{next_index}"][:name] = record["name"].delete(",")
        params[:invitation][:invitees_attributes]["#{next_index}"][:email] = record["email"]
        next_index += 1
      end
    end
  end

  def addSignupLinkToBody
    if params[:invitation][:organization_id] && params[:invitation][:organization_id] != "Select an Organization..."
      link = "\n\n" + new_user_url + "?organization=" + params[:invitation][:organization_id]
      params[:invitation][:body] = params[:invitation][:body] + link
    end
  end

  def inviteeStatus
    order_in = params[:reverse] != nil ? 'DESC' : 'ASC'
    order_by = params[:sort] != nil ? params[:sort] : 'email'
    #Invitee.paginate :page => params[:page] || 1, :order => order_by + " " + order_in, :conditions => ["invitation_id = ?", params[:id]]
    db = ActiveRecord::Base.connection();
    table = ""
    if params[:sort] != nil && (params[:sort] == 'completionStatus' && params[:reverse] == '1')
      db.execute "CREATE TEMPORARY TABLE inviteeStatusByRegistration#{params[:id]} TYPE=HEAP " +
        "(SELECT invitees.* FROM invitees, users WHERE invitees.invitation_id = #{params[:id]} AND invitees.email=users.email ORDER BY users.email_confirmed, invitees.email ASC)"
      db.execute "INSERT INTO inviteeStatusByRegistration#{params[:id]} (SELECT DISTINCT invitees.* FROM invitees, users WHERE invitees.invitation_id = #{params[:id]} AND invitees.email NOT IN (SELECT users.email FROM users) ORDER BY invitees.email ASC)"
    else
      db.execute "CREATE TEMPORARY TABLE inviteeStatusByRegistration#{params[:id]} TYPE=HEAP " +
        "(SELECT DISTINCT invitees.* FROM invitees, users WHERE invitees.invitation_id = #{params[:id]} AND invitees.email NOT IN (SELECT users.email FROM users) ORDER BY invitees.email ASC)"
      db.execute "INSERT INTO inviteeStatusByRegistration#{params[:id]} (SELECT invitees.* FROM invitees, users WHERE invitees.invitation_id = #{params[:id]} AND invitees.email=users.email ORDER BY users.email_confirmed, invitees.email ASC)"
    end

    if params[:sort] != nil && params[:sort] != 'completionStatus'
      sql = "SELECT * FROM inviteeStatusByRegistration#{params[:id]} ORDER BY #{order_by} #{order_in}"
    else
      sql = "SELECT * FROM inviteeStatusByRegistration#{params[:id]}"
    end
    params[:per_page] = params[:per_page] ? params[:per_page].to_i : 25
    params[:page] = params[:page] ? params[:page].to_i : 1
    sql += " LIMIT #{(params[:per_page] * params[:page]) - params[:per_page]},#{params[:per_page]}"
    invitees = Invitee.find_by_sql([sql])
    db.execute "DROP TABLE inviteeStatusByRegistration#{params[:id]}"
    invitees
  end
  
  def inviteeStatusByOrganization
    order_in = params[:reverse] == '1' ? 'DESC' : 'ASC'
    order_by = params[:sort] != nil ? params[:sort] : 'email'
    Invitee.paginate :page => params[:page] || 1, :order => order_by + " " + order_in, :conditions => ["invitation_id = ?", params[:id]], :include => [:user, :invitation]
  end

  def inviteeStatusByPendingRequests
    Invitee.paginate :page => params[:page] || 1, :order => "invitees.email ASC", :joins => [:user => :role_requests], :include => :user,
                     :conditions => ["invitation_id = ? AND users.email_confirmed = ? AND role_requests.id IS NOT ? AND role_requests.approver_id IS ? AND role_requests.jurisdiction_id IN (?)", params[:id], true, nil, nil, current_user.role_memberships.admin_roles.map{|rm| rm.jurisdiction.id}.join(",")]
  end

  def inviteeStatusByProfileUpdate
    order_in = params[:reverse] == '1' ? 'DESC' : 'ASC'
    order_by = params[:sort] != nil && params[:sort] != 'profileUpdated' ? params[:sort] : 'email'
    order_by = "display_name" if order_by == "name"
    invitation_time = Invitation.find(params[:id]).updated_at
    Invitee.paginate_all_by_invitation_id params[:id], 
      :page=>params[:page] || 1, :order=> "users.updated_at AND users.#{order_by} " + order_in, :include=> [:user, :invitation] #, :conditions => ["users.updated_at >= ? AND users.email_confirmed = ?", invitation_time, true]
  end
  
  def csv_download
    send_file Rails.root.join("tmp","invitee.csv"), :type=>"application/xls" 
  end
end
