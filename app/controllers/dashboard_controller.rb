class DashboardController < ApplicationController  
  skip_before_filter :login_required, :only => [:about]

  def index
	  @articles = Article.recent
  end

  def about
  end

  def hud
    DashboardController.app_toolbar "han"
  end
  
	def faqs
    DashboardController.app_toolbar "faqs"
	end
end