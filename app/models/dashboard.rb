class Dashboard < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods

  has_many :dashboard_portlets, :dependent => :destroy do
    def with_column(column)
      scoped :conditions => ["dashboards_portlets.column = ?", column]
    end

    def draft
      scoped :conditions => ["dashboards_portlets.draft = ?", true]
    end

    def published
      scoped :conditions => ["dashboards_portlets.draft = ?", false]
    end
  end

  has_many :portlets, :through => :dashboard_portlets, :dependent => :destroy do
    def with_column(column)
      scoped :conditions => ["dashboards_portlets.column = ?", column]
    end

    def draft
      scoped :conditions => ["dashboards_portlets.draft = ?", true]
    end

    def published
      scoped :conditions => ["dashboards_portlets.draft = ?", false]
    end
  end

  has_many :dashboard_audiences, :dependent => :destroy do
    def with_role(role)
      scoped :conditions => ["audiences_dashboards.role = ?", Dashboard::DashboardAudience::ROLES[role.to_sym]]
    end
  end

  has_many :audiences, :through => :dashboard_audiences, :dependent => :destroy do
    def with_role(role)
      scoped :conditions => ["audiences_dashboards.role = ?", Dashboard::DashboardAudience::ROLES[role.to_sym]]
    end
  end

  named_scope :draft, :include => :dashboard_portlets, :conditions => ["dashboards_portlets.draft = ?", true]

  named_scope :published, :include => :dashboard_portlets, :conditions => ["dashboards_portlets.draft = ?", false]

  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  accepts_nested_attributes_for :dashboard_audiences, :reject_if => Proc.new{|attributes| attributes["dashboard_id"] != self.id}

  after_create :add_default_audience

  def self.create(options={})
    author = options[:author]
    options.delete :author if author
    created = super options
    if author
      audience = created.audiences.first
      if audience
        audience.user_ids = [author.id]
        audience.recipients
      end
    end
    created
  end

  def columns draft=false
    self.read_attribute(draft ? "draft_columns" : "columns")
  end

  def config(options={})
    jsonConfig = []
    columns = (options[:draft].to_s == "true" ? self.draft_columns : self.columns)
    columnWidth = (1.0 / (columns || 3).to_f).round(2).to_s[1..-1]
    (columns || 3).times do |i|
      items = []

      p = options[:draft] ? self.portlets(true).draft.with_column(i) : self.portlets(true).published.with_column(i)
      items = p.map do |portlet|
        if portlet.valid?
          column = self.dashboard_portlets(true).find_by_portlet_id_and_draft(portlet.id, options[:draft].to_s == "true").column
          json = sanitizeJSON(ActiveSupport::JSON.decode(portlet.config))
          json["itemId"] = portlet.id
          json["xtype"] = portlet.xtype
          json["column"] = column
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

  def refresh_audiences
    self.audiences.map(&:refresh_recipients)
  end
  handle_asynchronously :refresh_audiences

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

  def add_default_audience
    if dashboard_audiences.blank?
      audience = Audience.new(:type => "Dashboard")
      Dashboard::DashboardAudience.create(:audience => audience, :dashboard => self, :role => Dashboard::DashboardAudience::ROLES[:publisher])
    end
  end
end