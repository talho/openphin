class Rollcall::SchoolsController < ApplicationController
  helper :rollcall
  before_filter :rollcall_required
  before_filter :set_toolbar, :except => :chart

  def index

    if current_user.schools.empty?
      flash[:notice] = "You do not have access to Rollcall, or do not have any schools in your jurisdiction(s)."
      redirect_to rollcall_path
    else
      redirect_to current_user.schools.first
    end
  end

  def show
    schools = current_user.schools.find( :order => "display_name")
    @school = School.find(params[:id])

    if @school
      @district = @school.district
    end

    respond_to do |format|
      if @school && schools.include?(@school)
        @chart=open_flash_chart_object(600, 300, school_chart_path(@school, params[:timespan]))
        format.html
        format.xml { render :xml => @school }
      else
        flash[:error] = "You do not have any schools or school does not exist"
        format.html
        format.xml { render :xml => "", :status => :unprocessable_entity }
      end
    end
  end

  def chart
    @school = School.find(params[:school_id])
    render :text => create_school_chart(@school, params[:timespan])
  end

  protected
  def set_toolbar
    toolbar = current_user.roles.include?(Role.find_by_name('Rollcall')) ? "rollcall" : "application"
    Rollcall::SchoolsController.app_toolbar toolbar
  end

  private
  include RollcallHelper
end
