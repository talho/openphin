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
        @articles = Article.recent
        feed_urls = Rails.env == "production" ? [
          "http://www.nhc.noaa.gov/gtwo.xml",
          "http://www.nhc.noaa.gov/nhc_at2.xml",
          "http://www.weather.gov/alerts-beta/tx.php?x=1"
         ] : []
        @entries = []
        begin
          feed_urls.each do |url|
            @entries += Feedzirra::Feed.fetch_and_parse(url).entries
          end
          @entries = @entries.sort{|a,b| b.published <=> a.published}[0..9]
        rescue
          @entries = nil
        end
      end

      format.json do
        dashboard = Dashboard.first
        render :json => {:dashboard => {:id => dashboard.id.to_s, :updated_at => Time.now.to_s, :config => dashboard.config}, :success => true}
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
