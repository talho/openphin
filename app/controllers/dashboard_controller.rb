class DashboardController < ApplicationController  
  skip_before_filter :login_required, :only => [:about]
  require 'feedzirra'
  

  def index
    DashboardController.app_toolbar "application"
	  @articles = Article.recent
    feed_urls = [
      "http://www.nhc.noaa.gov/nhc_at1.xml", 
      "http://www.nhc.noaa.gov/xml/OFFNT4.xml"
     ]
    entries = []
    feed_urls.each do |url|
      entries += Feedzirra::Feed.fetch_and_parse(url).entries
    end
    @entries = entries.sort{|a,b| b.published <=> a.published}[0..9]
  end

  def about
    DashboardController.app_toolbar "application"
  end

  def hud
    DashboardController.app_toolbar "han"
    @user = current_user
    @alerts = present_collection(current_user.recent_alerts.size > 0 ? current_user.recent_alerts.paginate(:page => params[:page], :per_page => 10) : [Alert.default_alert].paginate(:page => 1))
    respond_to do |format|
      format.html
      format.json do
        @alerts = [@alerts] unless @alerts.kind_of? Array
        headers["Access-Control-Allow-Origin"] = "*"
        jsonObject = @alerts.collect{ |alert| alert.iphone_format(acknowledge_alert_path(alert),alert.acknowledged_by_user?) }
        render :json => jsonObject
      end
    end
  end
  
	def faqs
    DashboardController.app_toolbar "faqs"
	end

end

