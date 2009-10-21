class School < ActiveRecord::Base
  belongs_to :district, :class_name => "SchoolDistrict"
end
