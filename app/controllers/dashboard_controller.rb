class DashboardController < ApplicationController  
  skip_before_filter :login_required, :only => [:about]
  require 'feedzirra'
  

  def index
    DashboardController.app_toolbar "application"
	  @articles = Article.recent
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
  end

  def about
    DashboardController.app_toolbar "application"
  end

  def hud
    DashboardController.app_toolbar "han"
    @user = current_user
    per_page = ( params[:per_page].to_i > 0 ? params[:per_page].to_i : 10 )
    @alerts = present_collection(current_user.recent_alerts.size > 0 ? current_user.recent_alerts.paginate(:page => params[:page], :per_page => per_page) : [Alert.default_alert].paginate(:page => 1))
    respond_to do |format|
      format.html
      format.json do
        unless @alerts.nil? || @alerts.empty? || ( @alerts.map(&:id) == [nil] ) # for dummy default alert
          jsonObject = @alerts.collect{ |alert| alert.iphone_format(acknowledge_alert_path(alert),alert.acknowledged_by_user?) }
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
end
