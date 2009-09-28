class ApprovalMailer < ActionMailer::Base

  def approval(request)
    recipients request.user.email
    from DO_NOT_REPLY
    subject "Request approved"
    body :request => request
  end

  def denial(request, admin)
    recipients request.user.email
    from DO_NOT_REPLY
    subject "Request denied"
    body :request => request, :admin => admin
  end

  def organization_approval(organization)
    if organization.contact.blank?
      recipients organization.contact_email
    else
      recipients organization.contact.email
    end
    from DO_NOT_REPLY
    subject "Confirmation of #{organization.name} organization registration"
    body :organization => organization
  end

  def organization_denial(organization)
    if organization.contact.blank?
      recipients organization.contact_email
    else
      recipients organization.contact.email
    end
    from DO_NOT_REPLY
    subject "Organization registration request denied"
    body :organization => organization
  end
end
