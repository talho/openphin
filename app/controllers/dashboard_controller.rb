class DashboardController < ApplicationController  
  skip_before_filter :login_required, :only => [:about]

  def index
    DashboardController.app_toolbar "application"
	  @articles = Article.recent
  end

  def about
    DashboardController.app_toolbar "application"
  end

  def hud
    DashboardController.app_toolbar "han"

    @alerts = present_collection(current_user.recent_alerts.size > 0 ? current_user.recent_alerts.paginate(:page => params[:page], :per_page => 10) : [Alert.default_alert].paginate(:page => 1))
  end
  
	def faqs
    DashboardController.app_toolbar "faqs"
	end
end