class AppMailer < ActionMailer::Base
  
  def role_assigned(role, jurisdiction, user)
    recipients user.email
    subject "Role assigned"
    body :role => role, :jurisdiction => jurisdiction, :user => user
  end
  
end