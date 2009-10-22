class School < ActiveRecord::Base
  belongs_to :district, :class_name => "SchoolDistrict", :foreign_key => "district_id"
  has_many :absentee_reports

  before_create :set_display_name

  private
  def set_display_name
    self.display_name = self.name if self.display_name.nil? || self.display_name.strip.blank?
  end
end
