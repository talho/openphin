
module UserModules
  module Dashboard
    def self.included(base)
      base.belongs_to :dashboard_default, :class_name => "::Dashboard", :foreign_key => "dashboard_id", :include => :dashboard_portlets, :conditions =>  ["dashboards_portlets.draft = ?", false]
    end
  
    def dashboards
      ::Dashboard.scoped :include => :dashboard_portlets, :joins => "JOIN audiences_dashboards ON (dashboards.id = audiences_dashboards.dashboard_id) JOIN audiences_recipients ON (audiences_recipients.audience_id = audiences_dashboards.audience_id)", :conditions => "audiences_recipients.user_id = #{self.id}"
    end
  
    def default_dashboard
      self.dashboards.published.find_by_id(self.dashboard_default) || self.dashboards.published.first || ::Dashboard.application_default.published.first
    end
  end
end