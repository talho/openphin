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
      format.json do
        for_admin = params[:for_admin].to_s == "true"
        if for_admin
          dashboards = Dashboard.with_user(current_user).with_roles('publisher', 'editor')
        else
          dashboards = current_user.dashboards.compact
        end
        
        render :json => {:dashboards => dashboards.map{ |d| d.as_json(:only => [:name, :id]) }, :success => true}
      end

      format.ext {render :layout => 'ext.html'}
    end
  end

  def show
    respond_to do |format|
      format.html do
        DashboardController.app_toolbar "application"
        expire_fragment(:controller => "dashboard", :action => "index") if DashboardController.expired?
      end

      format.json do
        dashboard = current_user.dashboards.find_by_id(params[:id]) || (current_user.default_dashboard.id == params[:id].to_i ? current_user.default_dashboard : nil)
        if dashboard
          render :json => {:dashboard => {:id => dashboard.id.to_s, :name => dashboard.name, :updated_at => Time.now.to_s, :columns => dashboard.columns, :config => dashboard.config, :draft => false} }
        else
          render :json => {:dashboard => {}, :success => false}
        end
      end

      format.ext {render :layout => 'ext.html'}
    end
  end  
  
  def edit
    respond_to do |format|
      format.json do
        dashboard = Dashboard.with_user(current_user).with_roles('publisher', 'editor').find(params[:id])
        dashboard = Dashboard.find_by_id_and_application_default(params[:id], true) if current_user.is_super_admin? && dashboard.nil?
        
        if dashboard
          render :json => {:dashboard => {:id => dashboard.id, :name => dashboard.name, :updated_at => dashboard.updated_at, :columns => dashboard.columns(true), :config => dashboard.config(:draft => true), :draft => true, :application_default => dashboard.application_default,
                                          :dashboard_audiences => dashboard.dashboard_audiences.map {|da| {:id => da[:id], :role => da[:role], 
                                                                                                           :audience => da.audience.as_json(:only => [], :include => {:roles => {:only => [:name, :id]}, 
                                                                                                                                                                      :jurisdictions => {:only => [:name, :id]}, 
                                                                                                                                                                      :groups => {:only => [:name, :id]}, 
                                                                                                                                                                      :users => {:only => [:display_name, :id, :email]} 
                                                                                                                                            }) 
                                                                                                     } } 
                                          }, :success => true}
        else
          render :json => {:dashboard => {}, :success => false}
        end
      end
    end
  end

  def create
    respond_to do |format|
      format.json do
        options = {:name => params[:dashboard][:name], :author => current_user, :columns => 3}
        draft = true
        dashboard = Dashboard.create(options)
        render :json => {:id => dashboard.id, :name => dashboard.name, :success => true}
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        update_it
      end
    end
  end

  def update_it
    dashboard_json = ActiveSupport::JSON.decode(params["dashboards"])
    dashboard = Dashboard.find_by_id(params[:id])
    dashboard.name = dashboard_json["name"] if dashboard_json["name"]
    draft = dashboard_json["draft"].blank? ? false : dashboard_json["draft"].to_s == "true"
    if dashboard_json["columns"]
      if draft
        dashboard.draft_columns = dashboard_json["columns"]
      else
        dashboard.columns = dashboard_json["columns"]
      end
    end
    if dashboard_json["application_default"] && current_user.is_super_admin?
      dashboard.application_default = dashboard_json["application_default"] == true
    end
    
    dashboard.dashboard_audiences_attributes = dashboard_json['dashboard_audiences_attributes'] unless dashboard_json['dashboard_audiences_attributes'].blank?
    portlet_ids = []
    if dashboard && dashboard.save
      config = dashboard_json["config"]
      config.length.times do |column|
        portlets = config[column]
        portlets["items"].each do |portlet|
          p = if portlet["itemId"]
            dp = dashboard.dashboard_portlets.find_by_portlet_id_and_draft(portlet["itemId"], draft)
            if dp
              dp["column"] = portlet["column"]
              dp.portlet["config"] = portlet
              dp.portlet.save && dp.save ? dp.portlet : nil
            elsif draft
              p = Portlet.create(:xtype => portlet["xtype"], :config => portlet)
              dashboard.dashboard_portlets.create(:portlet_id => p.id, :column => portlet["column"], :draft => draft)
              p
            else
              dp = dashboard.dashboard_portlets.find_by_portlet_id(portlet["itemId"])
              dp["draft"] = false
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
      
      if dashboard.application_default
        Dashboard.find_all_by_application_default(true, :conditions => ["id != ?", dashboard.id]).each{|d| d.update_attributes :application_default => false } 
      end

      dashboard.dashboard_portlets.find(:all, :conditions => ["dashboards_portlets.draft = ? AND \"dashboards_portlets\".portlet_id NOT IN (?)", draft, portlet_ids]).map(&:destroy) if portlet_ids.size

      dashboard.portlets.draft.map(&:destroy) unless draft

      render :json => {:success => true}
    else
      render :json => {:success => false}
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

  def all
    respond_to do |format|
      format.json do
        dashboards = current_user.dashboards.map do |dashboard|
          {:id => dashboard.id.to_s, :name => dashboard.name}
        end

        render :json => {:dashboards => dashboards, :success => true}
      end
    end
  end
end
