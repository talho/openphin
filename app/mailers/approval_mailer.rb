class ApprovalMailer < ActionMailer::Base

  def approval(request)
    recipients request.requester.email
    from EMAIL_FROM
    subject "Request approved"
    body :request => request
  end

  def denial(request, admin)
    recipients request.requester.email
    from EMAIL_FROM
    subject "Request denied"
    body :request => request, :admin => admin
  end

  def organization_approval(organization)
    recipients organization.contact.email
    from EMAIL_FROM
    subject "Confirmation of #{organization.name} organization registration"
    body :organization => organization
  end

  def organization_denial(organization)
    recipients organization.contact.email
    from EMAIL_FROM
    subject "Organization registration request denied"
    body :organization => organization
  end
end
