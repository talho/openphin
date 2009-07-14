class SignupMailer < ActionMailer::Base
  
  def confirmation(user)
    subject "Confirm your email"
    body :confirm_link => user_confirmation_path(user, user.token)
  end
  
end