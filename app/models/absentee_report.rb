class AbsenteeReport < ActiveRecord::Base
  belongs_to :school

  named_scope :for_date, lambda{ |date|
    {
      :conditions => {:report_date => date}
    }
  }
end
