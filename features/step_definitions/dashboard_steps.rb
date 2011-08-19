Given 'a default dashboard for "$email"' do |email|
  user = User.find_by_email!(email)
  Factory(:dashboard, :dashboard_audiences_attributes => {"1" => {:audience => Factory(:audience, :users => [user]), :role => "publisher"}})
end

Given /^a (\d+) column dashboard for "([^\"]*)" with:$/ do |columns, email, table|
  user = User.find_by_email!(email)
  rows = table.hashes
  dashboard_portlets_attributes = {}
  rows.each_index do |index|
    portlet = Factory(:portlet, :xtype => rows[index]['xtype'], :config => "--- \n#{rows[index]['content']}\ncolumn: #{rows[index]['column']}\ntype: #{rows[index]['xtype']}\n")
    dashboard_portlets_attributes[(index + 1).to_s] = {:portlet => Factory(:portlet), :draft => rows[index]['draft'], :column => rows[index]['column']}
  end
  dashboard_audiences_attributes = {"1" => {:audience => Factory(:audience, :users => [user]), :role => "publisher"}}
  Factory(:dashboard, :columns => columns, :draft_columns => columns, :dashboard_portlets_attributes => dashboard_portlets_attributes, :dashboard_audiences_attributes => dashboard_audiences_attributes)
end