class Dashboard < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods

  has_many :dashboard_portlets, :dependent => :destroy, :order => 'dashboards_portlets.sequence' do
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

  has_many :portlets, :through => :dashboard_portlets, :dependent => :destroy, :order => 'dashboards_portlets.sequence' do
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
  
  named_scope :with_user, lambda { |user|
    user_id = user.class == User ? user.id : user
    { :joins => send(:sanitize_sql_array,
      ["JOIN audiences_dashboards ON (dashboards.id = audiences_dashboards.dashboard_id) JOIN sp_audiences_for_user(?) au ON (au.id = audiences_dashboards.audience_id)", 
       user_id])
     }} do
      def with_roles(*roles)
        scoped :conditions => {"audiences_dashboards.role" => roles.to_a.flatten.map{|r| Dashboard::DashboardAudience::ROLES[r.to_sym] } }
      end
  end

  named_scope :draft, :include => :dashboard_portlets, :conditions => ["dashboards_portlets.draft = ?", true]

  named_scope :published, :include => :dashboard_portlets, :conditions => ["dashboards_portlets.draft = ?", false]

  named_scope :application_default, :conditions => {:application_default => true}

  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  accepts_nested_attributes_for :dashboard_portlets, :dashboard_audiences, :audiences #, :reject_if => Proc.new{|attributes| attributes["dashboard_id"] != self.id}

  after_create :add_default_audience

  def self.create(options={})
    author = options[:author]
    options.delete :author if author
    created = super options
    if author
      audience = created.audiences.first
      if audience
        audience.user_ids = [author.id]
        #audience.refresh_recipients(:force => true)
      end
    end
    created
  end

  def columns draft=false
    self.read_attribute(draft ? "draft_columns" : "columns")
  end

  def config(options={})
    jsonConfig = []
    columnWidth = (1.0 / (columns || 3)).round(2).to_s
    1.upto(columns || 3) do |i|
      items = []

      p = self.portlets(true).with_column(i)
      items = p.map do |portlet|
        if portlet.valid?
          column = self.dashboard_portlets(true).find_by_portlet_id(portlet.id).column
          json = sanitizeJSON(ActiveSupport::JSON.decode(portlet.config))
          json["itemId"] = portlet.id
          json["xtype"] = portlet.xtype
          json["column"] = column
          json
        end
      end.compact

      column = {
        :xtype => "portalcolumn",
        :columnWidth => columnWidth,
        :style => 'padding:5px',
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

  def add_default_audience
    if dashboard_audiences.blank?
      audience = Audience.create
      Dashboard::DashboardAudience.create(:audience => audience, :dashboard => self, :role => Dashboard::DashboardAudience::ROLES[:publisher])
    end
  end
end