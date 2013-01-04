class ReportSchedule < ActiveRecord::Base
  belongs_to :user

  validate :report_type, :uniqueness => {:scope => :user_id}
end
