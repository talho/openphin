class Admin::InvitationsController < ApplicationController
  
  def index
  end
  
  def show
  end
  
  def new
    @invitation = Invitation.new
  end
  
  def create
    @invitation = Invitation.new(params[:invitation])
    if @invitation.save
      flash[:notice] = "Invitation was successfully sent."
      redirect_to admin_invitation_path(@invitation)
    end
  end
  
  def destroy
  end
  
end
