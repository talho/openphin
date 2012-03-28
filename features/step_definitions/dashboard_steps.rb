
When /^I edit (?:a|the "([^"]*)") dashboard (?:on|as) "([^\"]*)"$/ do |dash_name, user_email|
  Then %{I am logged in as "#{user_email}"}
   And %{I wait for the "Loading..." mask to go away}
   And %{I press "Edit Dashboards"}
  if dash_name
     And %{I wait for the "Loading..." mask to go away}
    Then %{I press "Open"}
     And %{I select the "#{dash_name}" grid row}
     And %{I press "Open" within ".cms-open-dash-window"}
  end
  And %{I wait for the "Loading..." mask to go away}
end

Given /^the following dashboard exists:$/ do |table|
  FactoryGirl.create(:dashboard, table.rows_hash)
end

Given /^the "([^\"]*)" dashboard has the following portlet:$/ do |dash_name, table|
  dash = Dashboard.find_by_name(dash_name)
  dashboard_portlet_attributes = {:draft => false, :column => table.rows_hash[:column].to_i, :portlet_attributes => {:xtype => table.rows_hash[:xtype], :config => table.rows_hash[:config]} }
  dash.update_attributes :dashboard_portlets_attributes => [dashboard_portlet_attributes]
end

Given /^the "([^\"]*)" dashboard has the following audience:$/ do |dash_name, table|
  dash = Dashboard.find_by_name(dash_name)
  users = table.rows_hash[:Users] ? table.rows_hash[:Users].split(',').map {|u| User.find_by_display_name(u.strip) } : []
  roles = table.rows_hash[:Roles] ? table.rows_hash[:Roles].split(',').map {|r| Role.find_by_name(r.strip) } : []
  jurisdictions = table.rows_hash[:Jurisdictions] ? table.rows_hash[:Jurisdictions].split(',').map {|j| Jurisdiction.find_by_name(j.strip) } : []
  dashboard_audience_attributes = {:role => Dashboard::DashboardAudience::ROLES[table.rows_hash["Dashboard Role"].to_sym],
                                   :audience_attributes => {:jurisdictions => jurisdictions, :roles => roles, :users => users } }
  dash.update_attributes :dashboard_audiences_attributes => [dashboard_audience_attributes]
end

Then /^the "([^\"]*)" dashboard should( not)? exist$/ do |dash_name, neg|
  if neg
    Dashboard.find_by_name(dash_name).should be_nil
  else
    Dashboard.find_by_name(dash_name).should_not be_nil
  end
end

Then /^"([^\"]*)" should( not)? have a portlet with "([^\"]*)"(?: in column ([1-4]))?$/ do |dash_name, neg, portlet_content, col|
  dash = Dashboard.find_by_name(dash_name)
  port = nil
  dash.portlets.each do |p|
    if p.config =~ Regexp.new(portlet_content) && !(col && dash.dashboard_portlets.find_by_portlet_id(p.id).column != col.to_i)
      port = p
      break
    end
  end

  if neg
    port.should be_nil
  else
    port.should_not be_nil
  end
end

When /^I set ([0-9a-zA-Z\-]*) to ([0-9]*)$/ do |slider_class, number|
  slider = page.find(".#{slider_class}")
  page.execute_script("
    Ext.getCmp('#{slider["id"]}').setValue(#{number});
  ")
end

Then /^the "([^\"]*)" dashboard should have ([0-9]*) columns$/ do |dash_name, number|
  dash = Dashboard.find_by_name(dash_name)
  dash.columns.should == number.to_i
end

When /^I move the "([^\"]*)" portlet to position ([0-9]) in column ([1-4])$/ do |portlet_content, pos, col|
  # find the portlet using capybara finder
  portlet = page.find('.portlet', :text => portlet_content)

  # now use JS to fire a node drop
  begin
    page.execute_script("
      var portlet = Ext.getCmp('#{portlet['id']}'),
          portal = portlet.ownerCt.ownerCt,
          dd = {panel: portlet, proxy: {getProxy: function(){return {remove: function(){}};}} },
          e = {},
          data = {panel: portlet};

      portal.dd.lastPos = {c: portal.get(#{col.to_i - 1}), col: #{col.to_i - 1}, p: #{pos.to_i}};
      portal.dd.scrollPos = {top: 0}
      try{
        portal.dd.notifyDrop(dd, e, data);
      }catch(e){
        console.log(e);
        throw(e);
      }
    ")
  rescue Exception => e
    raise e
  end
end

Then /^"([^\"]*)" should come before the "([^\"]*)" for the "([^\"]*)" dashboard$/ do |portlet_content1, portlet_content2, dash_name|
  dash = Dashboard.find_by_name(dash_name)
  portal1 = nil
  portal2 = nil
  dash.portlets.each do |p|
    if p.config =~ Regexp.new(portlet_content1)
      portal1 = p
    elsif p.config =~ Regexp.new(portlet_content2)
      portal2 = p
    end

    if portal1 && portal2
      break;
    end
  end

  portal1.should_not be_nil
  portal2.should_not be_nil

  da1 = dash.dashboard_portlets.find_by_portlet_id(portal1.id)
  da2 = dash.dashboard_portlets.find_by_portlet_id(portal2.id)

  assert da1.sequence < da2.sequence
end

Then /^"([^\"]*)" should be a "([^\"]*)" for the "([^\"]*)" dashboard$/ do |user_name, role, dash_name|
  dashboards = Dashboard.with_user(User.find_by_display_name(user_name)).with_roles(role)
  assert dashboards.include?(Dashboard.find_by_name(dash_name))
end

When /^I maliciously try to create a dashboard$/ do
  page.execute_script("
    Ext.Ajax.request({
      url: '/dashboard.json',
      method: 'POST',
      params: {
        'dashboard[name]': 'TEST'
      },
      callback: function(o, s, r){
        window.responseText = r.responseText;
      }
    });
  ")
end

When /^I maliciously try to edit (?:a|the "([^"]*)") dashboard$/ do |dash_name|
  dash = dash_name ? Dashboard.find_by_name(dash_name) : Dashboard.first
  page.execute_script("
    Ext.Ajax.request({
      url: '/dashboard/#{dash.id}.json',
      method: 'PUT',
      params: {
        'dashboards': '{name: \"TEST\"}'
      },
      callback: function(o, s, r){
        window.responseText = r.responseText;
      }
    });
  ")
end

When /^I maliciously try to delete (?:a|the "([^"]*)") dashboard$/ do |dash_name|
  dash = dash_name ? Dashboard.find_by_name(dash_name) : Dashboard.first
  page.execute_script("
    Ext.Ajax.request({
      url: '/dashboard/#{dash.id}.json',
      method: 'DELETE',
      callback: function(o, s, r){
        window.responseText = r.responseText;
      }
    });
  ")
end

Then /^The maliciousness response should contain (?:\/([^\/]*)\/|"([^"]*)")$/ do |resp_text, resp_text2|
  resp_text ||= resp_text2
  resp = nil
  wait_until do
    resp = page.evaluate_script('window.responseText')
  end
  page.execute_script('delete window.responseText')
  resp.should =~ Regexp.new(resp_text)
end

When /^I load ExtJs$/ do
  page.execute_script("
    var s = document.createElement('SCRIPT');
    s.charset = 'UTF-8';
    s.src ='/javascripts/ext/adapter/ext/ext-base.js';
    document.getElementsByTagName('HEAD')[0].appendChild(s);
    var s2 = document.createElement('SCRIPT');
    s2.charset = 'UTF-8';
    s2.src ='/javascripts/ext/ext-all.js';
    document.getElementsByTagName('HEAD')[0].appendChild(s2);
  ")
end

Then /^I should not see the application default option in the permissions window$/ do
    When %{I press "Permissions"}
    Then %{I should not see "Make this the application default"}
end

When /^I check application default in the dashboard permission window$/ do
  Then %{I press "Permissions"}
   And %{I check "Make this the application default"}
   And %{I press "OK"}
end

Then /^"([^\"]*)" should be the default dashboard$/ do |dash_name|
  # first ensure that there is only one default dashboard
  dashes = Dashboard.find_all_by_application_default(true)
  dashes.count.should == 1
  dashes.first.should == Dashboard.find_by_name(dash_name)
end