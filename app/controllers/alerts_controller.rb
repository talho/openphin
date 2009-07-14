class AlertsController < ApplicationController
  def index
    
  end
  
  def new
    @alert = Alert.new
  end
end
