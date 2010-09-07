class DelayedJobCheck < ActiveRecord::Base
  def deliver
    deliver_status = AppMailer.deliver_delayed_job_check(@email)
    deliver_status == "200 OK"
  end

  handle_asynchronously :deliver
end
