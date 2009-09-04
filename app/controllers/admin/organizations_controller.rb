class Admin::OrganizationsController < ApplicationController
  before_filter :admin_required

  def approve
    if current_user.is_org_approver?
      org = Organization.find_by_id(params[:id])
      unless org.nil?
        org.update_attribute(:approved, true)
        ApprovalMailer.deliver_organization_approval(org)
        flash[:notice] = "You have approved the #{org.name} organization."
      else
        flash[:error] = "The organization does not exist. Has it been previously denied?"
      end
      redirect_to dashboard_path
    end
  end
  
  def deny
    if current_user.is_org_approver?
      org = Organization.find_by_id(params[:id])
      unless org.nil?
        ApprovalMailer.deliver_organization_denial(org)
        flash[:notice] = "You have denied the #{org.name} organization."
        org.destroy
      else
        flash[:error] = "The organization does not exist. Has it been previously denied?"
      end
      redirect_to dashboard_path
    end
  end

end
