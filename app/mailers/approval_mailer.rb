class ApprovalMailer < ActionMailer::Base

  def approval(request)
    recipients request.requester.email
    subject "Request approved"
    body :request => request
  end

  def denial(request, admin)
    recipients request.requester.email
    subject "Request approved"
    body :request => request, :admin => admin
  end

end
