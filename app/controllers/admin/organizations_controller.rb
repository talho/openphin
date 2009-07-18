class Admin::OrganizationsController < ApplicationController
  def approve
    if current_user.is_org_approver?
      org=Organization.find(params[:id])
      org.approved=true
      org.save
      ApprovalMailer.deliver_organization_approval(org)
      redirect_to dashboard_path
    end
  end
  
  def deny
    if current_user.is_org_approver?
      org = Organization.find(params[:id])
      ApprovalMailer.deliver_organization_denial(org)
      org.destroy
      redirect_to dashboard_path
    end
  end

end
