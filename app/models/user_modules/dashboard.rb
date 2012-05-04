
module UserModules
  module Dashboard
    def self.included(base)
      base.belongs_to :dashboard_default, :class_name => "::Dashboard", :foreign_key => "dashboard_id", :include => :dashboard_portlets, :conditions =>  ["dashboards_portlets.draft = ?", false]
    end
  
    def dashboards
      ::Dashboard.includes(:dashboard_portlets).joins("JOIN audiences_dashboards ON (dashboards.id = audiences_dashboards.dashboard_id) JOIN sp_audiences_for_user(#{self.id}) au ON (au.id = audiences_dashboards.audience_id)").where('')
    end
  
    def default_dashboard
      self.dashboards.published.find_by_id(self.dashboard_default) || ::Dashboard.application_default.include?(self.dashboard_default) ? self.dashboard_default : nil || self.dashboards.published.first || ::Dashboard.application_default.published.first
    end
  end
end