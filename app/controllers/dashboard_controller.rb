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
  end
  
	def faqs
    DashboardController.app_toolbar "faqs"
	end
end