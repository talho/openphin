class Admin::InvitationsController < ApplicationController
  require 'fastercsv'
  before_filter :admin_required
  app_toolbar "admin"

  def index
    @invitations = Invitation.all
  end
  
  def show
    @invitation = Invitation.find(params[:id])
  end
  
  def new
    @invitation = Invitation.new
  end
  
  def create
    paramsWithCSVInvitees unless params[:invitation][:csvfile].blank?
    params[:invitation].delete("csvfile")
    params[:invitation][:author_id] = current_user.id

    addSignupLinkToBody

    @invitation = Invitation.new(params[:invitation])
    if @invitation.save
      if @invitation.deliver
        flash[:notice] = "Invitation was successfully sent."
      else
        flash[:notice] = "Invitation was created but did not send."
      end
      redirect_to admin_invitation_path(@invitation)
    end
  end

  def reports
    invitation = Invitation.find(params[:id])
    report_options = [["By Email","by_email"], ["By Registrations","by_registrations"]]
    report_options << ["By Organization","by_organization"] unless invitation.default_organization.nil?
    report_options << ["By Pending Requests","by_pending_requests"]

    @reverse = params[:reverse] == "1" ? nil : "&reverse=1"

    case params[:report_type]
    when "by_registrations"
      results = inviteeStatus
      render :partial => "report_by_registration", :locals => {
        :results => results, :report_type => params[:report_type],
        :invitation => invitation, :report_options => report_options
      }, :layout => "application"
    when "by_organization"
      results = inviteeStatusByOrganization
      render :partial => "report_by_organization", :locals => {
        :results => results, :report_type => params[:report_type],
        :invitation => invitation, :report_options => report_options
      }, :layout => "application"
    when "by_pending_requests"
      results = inviteeStatusByPendingRequests
      render :partial => "report_by_pending_requests", :locals => {
        :results => results, :report_type => params[:report_type],
        :invitation => invitation, :report_options => report_options
      }, :layout => "application"
    else # Also by_email
      results = inviteeStatus
      render :partial => "report_by_email", :locals => {
        :results => results, :report_type => params[:report_type],
        :invitation => invitation, :report_options => report_options
      }, :layout => "application"
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
    FasterCSV.open(newfile, :col_sep => "|", :headers => true) do |records|
      records.each do |record|
        params[:invitation][:invitees_attributes] = [] if params[:invitation][:invitees_attributes].blank?
        params[:invitation][:invitees_attributes]["#{next_index}"] = {}
        params[:invitation][:invitees_attributes]["#{next_index}"][:name] = record["name"]
        params[:invitation][:invitees_attributes]["#{next_index}"][:email] = record["email"]
        next_index += 1
      end
    end
  end

  def addSignupLinkToBody
    if params[:invitation][:organization_id]
      link = "\n\n" + new_user_url + "?organization=" + params[:invitation][:organization_id]
      params[:invitation][:body] = params[:invitation][:body] + link
    end
  end

  def inviteeStatus
    order_in = params[:reverse] != nil ? 'DESC' : 'ASC'
    order_by = params[:sort] != nil ? params[:sort] : 'email'
    #Invitee.paginate :page => params[:page] || 1, :order => order_by + " " + order_in, :conditions => ["invitation_id = ?", params[:id]]
    db = ActiveRecord::Base.connection();
    if params[:sort] != nil && (params[:sort] == 'completion_status' && params[:reverse] == '1')
      db.execute "CREATE TEMPORARY TABLE inviteeStatusByRegistration TYPE=HEAP " +
        "(SELECT invitees.* FROM invitees, users WHERE invitees.invitation_id = #{params[:id]} AND invitees.email=users.email ORDER BY users.email_confirmed, invitees.email ASC)"
      db.execute "INSERT INTO inviteeStatusByRegistration (SELECT DISTINCT invitees.* FROM invitees, users WHERE invitees.invitation_id = #{params[:id]} AND invitees.email NOT IN (SELECT users.email FROM users) ORDER BY invitees.email ASC)"
    else
      db.execute "CREATE TEMPORARY TABLE inviteeStatusByRegistration TYPE=HEAP " +
        "(SELECT DISTINCT invitees.* FROM invitees, users WHERE invitees.invitation_id = #{params[:id]} AND invitees.email NOT IN (SELECT users.email FROM users) ORDER BY invitees.email ASC)"
      db.execute "INSERT INTO inviteeStatusByRegistration (SELECT invitees.* FROM invitees, users WHERE invitees.invitation_id = #{params[:id]} AND invitees.email=users.email ORDER BY users.email_confirmed, invitees.email ASC)"
    end

    if params[:sort] != nil && params[:sort] != 'completion_status'
      sql = "SELECT * FROM inviteeStatusByRegistration ORDER BY #{order_by} #{order_in}"
    else
      sql = "SELECT * FROM inviteeStatusByRegistration"
    end
    invitees = Invitee.paginate_by_sql [sql], :page => params[:page] || 1
    db.execute "DROP TABLE inviteeStatusByRegistration"
    invitees
  end
  
  def inviteeStatusByOrganization
    order_in = params[:reverse] == '1' ? 'DESC' : 'ASC'
    order_by = params[:sort] != nil ? params[:sort] : 'email'
    Invitee.paginate :page => params[:page] || 1, :order => order_by + " " + order_in, :conditions => ["invitation_id = ?", params[:id]]
  end

  def inviteeStatusByPendingRequests
    Invitee.paginate :page => params[:page] || 1, :order => "invitees.email ASC", :include => [:user => :role_requests],
                     :conditions => ["invitation_id = ? AND users.email_confirmed = ? AND role_requests.id IS NOT ? AND role_requests.approver_id IS ? AND role_requests.jurisdiction_id IN (?)", params[:id], true, nil, nil, current_user.role_memberships.admin_roles.map{|rm| rm.jurisdiction.id}.join(",")]
  end
end
