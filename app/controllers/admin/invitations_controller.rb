class Admin::InvitationsController < ApplicationController
  require 'csv'
  #before_filter :admin_required
  # before_filter :force_json_as_html, :only => :import
  include Report::CreateDataSet
  #extend ActiveSupport::Memoizable

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
        invitees = find_invitees.map{|i| {
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
        }
      end
    end
  end

  def reports
    begin
      @invitation = Invitation.find(params[:id])
      respond_to do |format|
        format.html
        format.any(:csv,:pdf) do
          criteria = {:model=>"Invitation",:method=>:find_by_id,:params=>@invitation[:id]}
          report = create_data_set(params[:report_id],criteria)
          render :json => {:success => true, :report_name=> report.name}
        end
      end
    rescue ActiveRecord::RecordInvalid => error
      render :json => {:success => false, :report_name => params[:report_id], :error => error }
    end
  end

  def recipe_types
    recipe_names = RecipeInternal.recipe_names.grep(/^RecipeInternal::Invitation/)
    selection = recipe_names.collect{|r| { :id => r, :name_humanized => RecipeInternal.humanized(r) } }
    respond_to do |format|
      format.json do
        render :json => {:success=>true, :recipes=>selection  }
      end
    end
  rescue StandardError => error
    render :json => {:success => false, :error => error}
  end
  #memoize :recipe_types

  def new
    @invitation = Invitation.new
  end

  def import
    invitees = []
    csvfile = params[:invitation][:csvfile]
    newfile = File.join(Rails.root.to_s,'tmp',csvfile.original_filename)
    File.open(newfile,'wb') do |file|
      file.puts csvfile.read
    end
    error = nil

    begin
      CSV.open(newfile, :col_sep => ",", :headers => true) do |records|
        records.each do |record|
          invitees.push({:name => record["name"].delete(","), :email => record["email"]})
        end
      end
    rescue CSV::MalformedCSVError => detail
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
            render :json => {:success => true, :flash => 'Invitation was successfully sent'}
          else
            render :json => {:success => false, :error => 'Invitation was created but did not send'}
          end
        end
      end
    end
  end

  def destroy
  end

  private

  def paramsWithCSVInvitees
    csvfile = params[:invitation][:csvfile]
    newfile = File.join(Rails.root.to_s,'tmp',csvfile.original_filename)
    File.open(newfile,'wb') do |file|
      file.puts csvfile.read
    end
    next_index = 0

    params[:invitation][:invitees_attributes].each do |key, value|
      next_index = key.to_i + 1 if key.to_i >= next_index
    end unless params[:invitation][:invitees_attributes].blank?

     begin
       lineno = 2
      CSV.open(newfile, :col_sep => ",", :headers => true, :skip_blanks => true, :header_converters => :symbol) do |records|
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

  def find_invitees
    params[:dir] ||= 'DESC'
    params[:sort] = params[:sort] ? params[:sort].underscore : 'name'
    
    params[:per_page] = params[:limit].to_i || 20
    params[:page] = (params[:start].to_i / params[:limit].to_i) + 1
    
    invitees = case params[:sort]
      when 'completion_status'
        @invitation.invitees.joins("LEFT JOIN users ON invitees.email = users.email").order("users.id #{params[:dir]}")
      when 'pending_requests'
        @invitation.invitees.joins("LEFT JOIN users ON invitees.email = users.email LEFT JOIN role_requests ON users.id = role_requests.user_id").order("role_requests.role_id #{params[:dir]}")
      when 'organization_membership'
        @invitation.default_organization ? 
        @invitation.invitees.joins("LEFT JOIN users ON invitees.email = users.email LEFT JOIN sp_recipients(#{@invitation.default_organization.group.id}) r on users.id = r.id").order("r.id #{params[:dir]}") :
        @invitation.invitees
      when 'profile_updated'
        @invitation.invitees.joins("LEFT JOIN users ON invitees.email = users.email").order("users.updated_at #{params[:dir]}")
      else
        @invitation.invitees.order("#{params[:sort]} #{params[:dir]}")
    end 
    
    invitees.order("invitees.name ASC").paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def csv_download
    send_file Rails.root.join("tmp","invitee.csv"), :type=>"application/xls" 
  end
end
