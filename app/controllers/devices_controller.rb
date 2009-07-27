class DevicesController < ApplicationController
  
  def destroy
    @device = Device.find(params[:id])
    @device.destroy
    redirect_to :back
  end

end
