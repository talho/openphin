class App < ActiveRecord::Base
  has_many :roles
  belongs_to :root_jurisdiction, :class_name => "Jurisdiction"
  
  has_attached_file :logo, :styles => {:full => "650", :thumb => "150"}, :default_url => "/assets/resources/images/Ocean/s.gif"
  has_attached_file :tiny_logo, :styles => {:full => "x28", :thumb => "x50>"}, :default_url => "/assets/resources/images/Ocean/s.gif"
  
  before_logo_post_process :transliterate_logo_file_name
  before_tiny_logo_post_process :transliterate_tiny_logo_file_name
  
  validates_uniqueness_of :name
    
  private 
  
  def transliterate_logo_file_name
    filename = URI.escape(self.logo_file_name)
    self.logo.instance_write(:file_name, filename)
  end
  
  def transliterate_tiny_logo_file_name
    filename = URI.escape(self.tiny_logo_file_name)
    self.tiny_logo.instance_write(:file_name, filename)
  end
end
