class DelayedJobCheck < ActiveRecord::Base
  validates_presence_of :email
  validates_format_of :email, :with => %r{^(?:[a-zA-Z0-9_'^&amp;/+-])+(?:\.(?:[a-zA-Z0-9_'^&amp;/+-])+)*@(?:(?:\[?(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))\.){3}(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\]?)|(?:[a-zA-Z0-9-]+\.)+(?:[a-zA-Z]){2,}\.?)$}
  validates_format_of :email, :with => %r{[^\.]$}


  def deliver
    deliver_status = AppMailer.deliver_delayed_job_check(email)
    deliver_status == "200 OK"
  end

  handle_asynchronously :deliver
end
