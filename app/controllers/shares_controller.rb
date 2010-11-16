class SharesController < ApplicationController
  before_filter :non_public_role_required

  layout "documents", :except => "popup_share"
  layout "application", :only => "popup_share"

  def new
    @share = Share.new({:user_id => current_user.id})
  end

  def create
    @share = current_user.owned_shares.build(params[:share])
    current_user.save!
    flash[:notice] = 'Successfully created the share'
    redirect_to documents_panel_path
  end

  def show
    @share = Share.find(params[:id])
    @documents = @share.documents
  end

  def edit_audience
    @share = Share.find(params[:id])
  end

  def update_audience
    @share = Share.find(params[:id])

    recipients = Array.new(@share.audience.recipients)

    @share.audience.update_attributes(params[:audience])
    @share.audience.recipients.with_refresh(:force => true)
    
    if(params[:notify] != false)
      DocumentMailer.deliver_share_invitation(@share, {:creator => current_user, :users => (@share.audience.recipients(:conditions => ["role_memberships.role_id <> ?", Role.public.id]).with_refresh - recipients) } )
    end

    redirect_to documents_panel_path
  end

  def unsubscribe
    share = Share.find(params[:id])
    unless(share.owner == current_user)
      share.opt_out_users << current_user
      flash[:notice] = "Successfully unsubscribed from the share"
    else
      flash[:notice] = "You can not be removed as owner, since you are the owner"
    end
    redirect_to documents_panel_path
  end
  
  def destroy
    @share = current_user.owned_shares.find(params[:id])
    @share.destroy
    flash[:notice] = "Successfully deleted the share"
    redirect_to documents_panel_path
  end
  
  def show_destroy
    @share = current_user.owned_shares.find(params[:id])
  end

  def popup_share
    @share = current_user.shares.find(params[:id])
  end
end
