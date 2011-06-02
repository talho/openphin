class Dashboard < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  
  has_many :dashboard_portlets do
    def with_column(column)
      scoped :conditions => ["dashboards_portlets.column = ?", column]
    end
  end
  has_many :portlets, :through => :dashboard_portlets do
    def with_column(column)
      scoped :conditions => ["dashboards_portlets.column = ?", column]
    end
  end
  has_many :dashboard_audiences do
    def with_role(role)
      scoped :conditions => ["audiences_dashboards.role = ?", Dashboard::DashboardAudience::ROLES[role.to_sym]]
    end
  end
  has_many :audiences, :through => :dashboard_audiences do
    def with_role(role)
      scoped :conditions => ["audiences_dashboards.role = ?", Dashboard::DashboardAudience::ROLES[role.to_sym]]
    end
  end
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  def config
    jsonConfig = []
    columnWidth = (1.0 / self.columns.to_f).round(2).to_s[1..-1]
    self.columns.times do |i|
      items = []

      items = self.portlets.with_column(i).map do |portlet|
        if portlet.valid?
          json = sanitizeJSON(ActiveSupport::JSON.decode(portlet.config))
          json["xtype"] = portlet.xtype
          json
        end
      end.compact

      column = {
        :xtype => "dashboardportalcolumn",
        :columnWidth => columnWidth,
        :style => 'padding:10px 0 10px 10px',
        :items => items
      }
      jsonConfig << column
    end
    jsonConfig
  end

  private
  def sanitizeJSON json
    json.keys.each do |key|
      case json[key].class.to_s
      when "Hash"
        json[key] = sanitizeJSON json[key]
      when "String"
        json[key] = sanitize(json[key])
      end
    end
    json
  end
end