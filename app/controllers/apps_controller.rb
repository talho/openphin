class AppsController < ApplicationController
  respond_to :json

  ##
  # Return all apps that a user currently has access to
  ##
  def index
    respond_with(@apps = current_user.apps)
  end
  
  ##
  # Return any apps that the user does not have access to
  ##
  def available
    respond_with(@apps = App.where("id NOT IN (?) AND name != 'system'", current_user.apps))
  end
  
  ##
  # Add user to the public role in an additional app they select
  ##
  def update
    app = App.find(params[:id])
    role = app.roles.where(public: true).first
    jur = current_user.home_jurisdiction || app.root_jurisdiction
    if !role.nil? && !current_user.role_memberships.where(role_id: role.id, jurisdiction_id: jur.id).exists? && current_user.role_memberships.create(role_id: role.id, jurisdiction_id: jur.id)
      render 'application/success' # We're doing ajax, on-the-fly updates here, no need to return the full item
    else
      respond_with @errors = current_user.errors, status: 400 do |format|
        format.any { render 'application/failure'}
      end
    end
  end
end
