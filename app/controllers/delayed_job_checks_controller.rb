class DelayedJobChecksController < ApplicationController
  def index
    @test_message = DelayedJobCheck.new
  end

  def create
    @test_message = DelayedJobCheck.new(params[:delayed_job_check])
    if @test_message.save
      if @test_message.deliver
        flash[:notice] = "Test message was successfully sent."
      else
        flash[:notice] = "Test message was created but did not send."
      end
      redirect_to delayed_job_checks_path
    else
      render :action => "index"
    end
  end
end
