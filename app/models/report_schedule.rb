class ReportSchedule < ActiveRecord::Base
  belongs_to :user

  validates :report_type, :uniqueness => {:scope => :user_id}
end
