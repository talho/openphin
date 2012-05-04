class ApprovalMailer < ActionMailer::Base
  default :from => DO_NOT_REPLY
  
  def approval(request)
    @request = request
    
    mail(to: request.user.email,
         subject: "Request approved")
  end

  def denial(request, admin)
    @request = request
    @admin = admin
    
    mail(to: request.user.email,
         subject: "Request denied")
  end

  def organization_approval(organization)
    @organization = organization
    
    mail(to: organization.contact.blank? ? organization.contact_email : organization.contact.email,
         subject: "Confirmation of #{organization.name} organization registration")    
  end

  def organization_denial(organization)
    @organization = organization
    
    mail(to: organization.contact.blank? ? organization.contact_email : organization.contact.email,
         subject: "Organization registration request denied")
  end
end
