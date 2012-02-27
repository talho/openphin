class OrganizationsController < ApplicationController
  layout false
  
  def index
    @organizations = Organization.all
  end

end
