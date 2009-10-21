class School < ActiveRecord::Base
  belongs_to :district, :class_name => "SchoolDistrict", :foreign_key => "district_id"
  has_many :absentee_reports
  
end
