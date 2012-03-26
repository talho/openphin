class ApprovalMailer < ActionMailer::Base
  default :from => DO_NOT_REPLY
  
  def approval(request)
    recipients request.user.email
    subject "Request approved"
    body :request => request
  end

  def denial(request, admin)
    recipients request.user.email
    subject "Request denied"
    body :request => request, :admin => admin
  end

  def organization_approval(organization)
    if organization.contact.blank?
      recipients organization.contact_email
    else
      recipients organization.contact.email
    end
    subject "Confirmation of #{organization.name} organization registration"
    body :organization => organization
  end

  def organization_denial(organization)
    if organization.contact.blank?
      recipients organization.contact_email
    else
      recipients organization.contact.email
    end
    subject "Organization registration request denied"
    body :organization => organization
  end
end
