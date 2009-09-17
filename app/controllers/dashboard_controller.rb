class DashboardController < ApplicationController  
  skip_before_filter :login_required, :only => [:about]
  def index
  end

  def about
  end
end