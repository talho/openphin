class DelayedJobCheck < ActiveRecord::Base
  validates_presence_of :email
  validates_format_of :email, :with => %r{^(?:[a-zA-Z0-9_'^&amp;/+-])+(?:\.(?:[a-zA-Z0-9_'^&amp;/+-])+)*@(?:(?:\[?(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))\.){3}(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\]?)|(?:[a-zA-Z0-9-]+\.)+(?:[a-zA-Z]){2,}\.?)$}
  validates_format_of :email, :with => %r{[^\.]$}
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  def deliver
    deliver_status = AppMailer.delayed_job_check(email).deliver
    deliver_status == "200 OK"
  end

  def to_s
    email
  end

  handle_asynchronously :deliver
end
