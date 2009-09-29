class DashboardController < ApplicationController  
  skip_before_filter :login_required, :only => [:about]
  app_toolbar "han"
  def index
	  @articles = Article.recent
  end

  def about
  end
end