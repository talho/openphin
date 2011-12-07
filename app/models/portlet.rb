class Portlet < ActiveRecord::Base
  has_many :dashboards
  has_many :dashboard_portlets, :class_name => "Dashboard::DashboardPortlet", :dependent => :destroy
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  validate :valid_xtype?

  private
  def valid_xtype?
    errors.add_to_base("Invalid portlet xtype") unless ["dashboardhtmlportlet", "dashboardphinportlet"].include?(self.xtype)
  end
end