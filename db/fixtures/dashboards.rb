# create a default dashboard if there isn't one already
if Dashboard.application_default.empty?
  dash = Dashboard.new( :application_default => true, :columns => 1, :name => 'Application Default')
  dash.dashboard_portlets.build(:draft => false, :column => 1, :portlet => Portlet.new(:xtype => 'dashboardhtmlportlet', :config => '{"html": "<h1>Welcome to openPHIN</h1>"}'))
  dash.save
end