# == Schema Information
#
# Table name: alerts
#
#  id          :integer         not null, primary key
#  title       :string(255)
#  message     :text
#  severety    :string(255)
#  status      :string(255)
#  acknowledge :boolean
#  author_id   :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Alert < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  has_and_belongs_to_many :users
  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :organizations
  
  Statuses = ['Actual', 'Exercise', 'Test']
  Severities = ['Extreme', 'Severe', 'Moderate', 'Minor', 'Unknown']
  
  validates_inclusion_of :status, :in => Statuses
  validates_inclusion_of :severity, :in => Severities
  
  def after_initialize
    self.acknowledge = true if acknowledge.nil?
  end
  
end
