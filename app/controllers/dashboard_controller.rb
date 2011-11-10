class DashboardController < ApplicationController
  skip_before_filter :authenticate, :only => [:about]
  before_filter :non_public_role_required, :only => [:new, :create, :edit, :update, :delete]
  require 'feedzirra'

  def index
    user = params[:user_id] ? User.find(params[:user_id]) : current_user
    respond_to do |format|
      format.json do
        for_admin = params[:for_admin].to_s == "true"
        if for_admin
          dashboards = Dashboard.with_user(current_user).with_roles('publisher', 'editor')
          if current_user.is_super_admin?
            dashboards << Dashboard.application_default.first
          end
        elsif user == current_user || current_user.is_admin_for?(user)
          dashboards = user.dashboards.compact
          dashboards << Dashboard.application_default.first
        else
          dashboards = []
        end
        
        render :json => {:dashboards => dashboards.uniq.map{ |d| d.as_json(:only => [:name, :id]) }, :success => true}
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

      format.ext do
        @path = session[:path]
        session[:path] = nil
        render :layout => 'ext.html'
      end
      
      format.json do
        dashboard = current_user.dashboards.find_by_id(params[:id]) || (current_user.default_dashboard.id == params[:id].to_i ? current_user.default_dashboard : nil)
        if dashboard
          render :json => {:dashboard => {:id => dashboard.id.to_s, :name => dashboard.name, :updated_at => Time.now.to_s, :columns => dashboard.columns, :config => dashboard.config, :draft => false} }
        else
          render :json => {:dashboard => {}, :success => false}
        end
      end
    end
  end  
  
  def edit
    respond_to do |format|
      format.json do
        dashboard = Dashboard.with_user(current_user).with_roles('publisher', 'editor').find_by_id(params[:id])
        dashboard = Dashboard.find_by_id_and_application_default(params[:id], true) if current_user.is_super_admin? && dashboard.nil?
        
        if dashboard
          render :json => {:dashboard => {:id => dashboard.id, :name => dashboard.name, :updated_at => dashboard.updated_at, 
                                          :columns => dashboard.columns(true), :config => dashboard.config(:draft => true), :draft => true, 
                                          :application_default => dashboard.application_default,
                                          :dashboard_audiences => dashboard.dashboard_audiences.map {|da| 
                                            {:id => da[:id], :role => da[:role], 
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
    dashboard_json = ActiveSupport::JSON.decode(params["dashboards"]) if params["dashboards"]
    dashboard = Dashboard.with_user(current_user).with_roles('publisher', 'editor').find_by_id(params[:id])
    dashboard = Dashboard.find_by_id_and_application_default(params[:id], true) if current_user.is_super_admin? && dashboard.nil?
    
    if dashboard.nil?
      render :json => {:success => false}, :status => 400
      return
    end
    
    dashboard = Dashboard.find(dashboard.id) # fix an issue with a readonly record, whatever that is
    
    dashboard.name = dashboard_json["name"] if dashboard_json["name"]
    
    dashboard.columns = dashboard_json["columns"] if dashboard_json["columns"]
    
    if dashboard_json["application_default"] && current_user.is_super_admin?
      dashboard.application_default = dashboard_json["application_default"] == true
    end
    
    dashboard.dashboard_audiences_attributes = dashboard_json['dashboard_audiences_attributes'] unless dashboard_json['dashboard_audiences_attributes'].blank?
    portlet_ids = []
    if dashboard && dashboard.save
      config = dashboard_json["config"]
      config.length.times do |column|
        portlets = config[column]
        portlets["items"].each_with_index do |portlet, index|
          p = if portlet["itemId"] && dp = dashboard.dashboard_portlets.find_by_portlet_id(portlet["itemId"])
            dp.attributes = { :draft => false, :column => portlet["column"], :sequence => index } 
            dp.portlet["config"] = portlet
            dp.portlet.save && dp.save ? dp.portlet : nil
          else
            p = Portlet.create(:xtype => portlet["xtype"], :config => portlet)
            dashboard.dashboard_portlets.create(:portlet_id => p.id, :column => portlet["column"], :draft => false, :sequence => index)
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
      
      dashboard.dashboard_audiences.each{|da| da.audience.refresh_recipients(:force => true)}
      
      portlet_ids << 0 if portlet_ids.empty? # fix an issue where NOT IN *empty array* was coming across as NOT IN (NULL) which was never returning anything anyway. id's are 1 indexed, so there will never be a 0 id.
      dashboard.dashboard_portlets.find(:all, :conditions => ["\"dashboards_portlets\".portlet_id NOT IN (?)", portlet_ids]).map(&:destroy)

      render :json => {:success => true}
    else
      render :json => {:success => false}
    end
  end

  def destroy
    def render_error(msg, status=400, errors=nil)
      render :json => {:success => false, :msg => msg, :errors => errors }, :status => status
    end
    
    respond_to do |format|
      format.json do
        dashboard = Dashboard.with_user(current_user).with_roles('publisher', 'editor').find_by_id(params[:id])
        if dashboard && !dashboard.application_default
          dashboard = Dashboard.find(dashboard.id) # get around read-only record issue
          if dashboard.destroy
            render :json => {:success => true}
          else
            render_error("Dashboard was not found", 400, dashboard.errors)
          end
        else
          if !dashboard && current_user.is_super_admin?
            dashboard = Dashboard.find_by_id(params[:id]) # get the dashboard anyway to check and see if it's application default
          end
          
          if dashboard && dashboard.application_default # we have permission to edit this dashboard, but it's app default
            render_error("Cannot delete application default dashboard", 400)
          else
            render_error("Dashboard was not found", 404)
          end
        end
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
    @alerts = present_collection((defined?(current_user.recent_han_alerts) && current_user.recent_han_alerts.size > 0) ? 
                current_user.recent_han_alerts.paginate(:page => params[:page], :per_page => per_page) : 
                (defined?(HanAlert) ? [HanAlert.default_alert] : []).paginate(:page => 1))
    respond_to do |format|
      format.html
      format.ext
      format.json do
        unless @alerts.nil? || @alerts.empty? || ( @alerts.map(&:id) == [nil] ) # for dummy default alert
          jsonObject = @alerts.collect{ |alert| alert.iphone_format(acknowledge_han_alert_path(alert.id),alert.acknowledged_by_user?) }
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
