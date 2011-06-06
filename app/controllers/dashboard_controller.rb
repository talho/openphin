class DashboardController < ApplicationController
  skip_before_filter :login_required, :only => [:about]
  require 'feedzirra'

  #layout if_not_ext 'application' #disable the default layout for ext requests
  #  layout 'application'
  def self.expired?
    if @expire_time && Time.now.utc.hour == @expire_time.hour
      true
    else
      @expire_time = Time.now.utc
      false
    end
  end

  def index
    respond_to do |format|
      format.html do
        DashboardController.app_toolbar "application"
        expire_fragment(:controller => "dashboard", :action => "index") if DashboardController.expired?
      end

      format.json do
        dashboard = current_user.dashboards.published.find_by_id(current_user.dashboard_default) || current_user.dashboards.published.first
        if dashboard
          render :json => {:dashboard => {:id => dashboard.id.to_s, :name => dashboard.name, :updated_at => Time.now.to_s, :columns => dashboard.columns, :config => dashboard.config(:draft => false), :draft => false}, :success => true}
        else
          render :json => {:dashboard => {}, :success => true}
        end
      end

      format.ext {render :layout => 'ext.html'}
    end
  end

  def create
    respond_to do |format|
      format.json do
        dashboard_json = ActiveSupport::JSON.decode(params["dashboard"])
        dashboard = Dashboard.create(:name => dashboard_json["name"] || "", :columns => dashboard_json["columns"], :dashboard_audiences_attributes => dashboard_json["dashboard_audiences_attributes"] || {})
        draft = dashboard_json["draft"].blank? ? false : dashboard_json["draft"]
        config = dashboard_json["config"]
        config.length.times do |column|
          portlets = config[column]
          portlets["items"].each do |portlet|
            p = Portlet.create(:xtype => portlet["xtype"], :config => portlet)
            dashboard.dashboard_portlets.create(:portlet_id => p.id, :column => portlet["column"], :draft => draft)
            portlet["id"] = p.id
          end
        end

        render :json => {:dashboard => {:id => dashboard.id.to_s, :name => dashboard.name, :updated_at => Time.now.to_s, :config => dashboard.config({:draft => draft}), :draft => draft}, :success => true}
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        dashboard_json = ActiveSupport::JSON.decode(params["dashboard"])
        dashboard = Dashboard.find_by_id(params[:id])
        dashboard.name = dashboard_json["name"] if dashboard_json["name"]
        dashboard.columns = dashboard_json["columns"] if dashboard_json["columns"]
        draft = dashboard_json["draft"].blank? ? false : dashboard_json["draft"]
        portlet_ids = []
        if dashboard && dashboard.save
          config = dashboard_json["config"]
          config.length.times do |column|
            portlets = config[column]
            portlets["items"].each do |portlet|
              p = if portlet["itemId"]
                dp = dashboard.dashboard_portlets.find_by_portlet_id(portlet["itemId"])
                if dp
                  dp["column"] = portlet["column"]
                  dp.portlet["config"] = portlet
                  dp.portlet.save && dp.save ? dp.portlet : nil
                end
              else
                p = Portlet.create(:xtype => portlet["xtype"], :config => portlet)
                dashboard.dashboard_portlets.create(:portlet_id => p.id, :column => portlet["column"], :draft => draft)
                p
              end

              unless p
                render :json => {:success => false}
                return
              end

              portlet["id"] = p.id
              portlet_ids.push(p.id)
            end
          end

          dashboard.dashboard_portlets.find(:all, :conditions => ["dashboards_portlets.draft = ? AND \"dashboards_portlets\".portlet_id NOT IN (?)", draft, portlet_ids]).map(&:destroy) if portlet_ids.size

          dashboard.portlets.draft.map(&:destroy) unless draft

          render :json => {:dashboard => {:id => dashboard.id.to_s, :name => dashboard.name, :updated_at => Time.now.to_s, :config => dashboard.config({:draft => draft}), :draft => draft}, :success => true}
        else
          render :json => {:success => false}
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        dashboard = Dashboard.find_by_id(params[:id])
        render :json => {:success => (dashboard && dashboard.destroy)}
      end
    end
  end

  def about
    DashboardController.app_toolbar "application"
  end

  def hud
    DashboardController.app_toolbar "han"
    @user = current_user
    per_page = ( params[:per_page].to_i > 0 ? params[:per_page].to_i : 10 )
    @alerts = present_collection((defined?(current_user.recent_han_alerts) && current_user.recent_han_alerts.size > 0) ? current_user.recent_han_alerts.paginate(:page => params[:page], :per_page => per_page) : (defined?(HanAlert) ? [HanAlert.default_alert] : []).paginate(:page => 1))
    respond_to do |format|
      format.html
      format.ext
      format.json do
        unless @alerts.nil? || @alerts.empty? || ( @alerts.map(&:id) == [nil] ) # for dummy default alert
          jsonObject = @alerts.collect{ |alert| alert.iphone_format(acknowledge_han_alert_path(alert),alert.acknowledged_by_user?) }
          headers["Access-Control-Allow-Origin"] = "*"
          render :json => jsonObject
        else
          headers["Access-Control-Allow-Origin"] = "*"
          render :json => []
        end
      end
    end
  end
  
	def faqs
    DashboardController.app_toolbar "faqs"
    end

  def feed_articles
    feed_urls = [
      "http://www.nhc.noaa.gov/gtwo.xml",
      "http://www.nhc.noaa.gov/nhc_at2.xml",
      "http://www.weather.gov/alerts-beta/tx.php?x=1"
     ]
    @entries = []
    begin
      feed_urls.each do |url|
        @entries += Feedzirra::Feed.fetch_and_parse(url).entries
      end
      @entries = @entries.sort{|a,b| b.published <=> a.published}[0..9]
    rescue
      @entries = nil
    end

    respond_to do |format|
      format.html {render :partial => 'feed_articles', :locals => {:entries => @entries}}
      format.json {render :json => @entries}
    end
  end

  def news_articles
    render :partial => 'news_articles.html'
  end

  def menu
  end
end
