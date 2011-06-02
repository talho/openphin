class Dashboard::DashboardPortlet < ActiveRecord::Base
  set_table_name "dashboards_portlets"
  belongs_to :dashboard
  belongs_to :portlet
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }
end