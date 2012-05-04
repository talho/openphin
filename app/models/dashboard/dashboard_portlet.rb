class Dashboard::DashboardPortlet < ActiveRecord::Base
  self.table_name = "dashboards_portlets"
  belongs_to :dashboard
  belongs_to :portlet, :dependent => :destroy
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  scope :draft, :conditions => {:draft => true}
  scope :published, :conditions => {:draft => false}
  
  accepts_nested_attributes_for :portlet
end