class Rollcall::SchoolsController < ApplicationController
  helper :rollcall
  before_filter :rollcall_required

  def index
    toolbar = current_user.roles.include?(Role.find_by_name('Rollcall')) ? "rollcall" : "application"
    Rollcall::SchoolsController.app_toolbar toolbar

    schools = current_user.schools
    if params["district"] && !params["district"][:id].blank? && (!params["school"] || params["school"][:id].blank?)
      @school = SchoolDistrict.find(params["district"][:id]).schools.first
    elsif params["school"] && !params["school"][:id].blank?
      @school = School.find(params["school"][:id])
    else
      @school = schools.first
    end

    if @school
      @district = @school.district
    end

    respond_to do |format|
      if @school && schools.include?(@school)
        format.html
        format.xml { render :xml => @school }
      else
        flash[:error] = "You do not have any schools"
        format.html
        format.xml { render :xml => "", :status => :unprocessable_entity }
      end
    end
  end

  def show
    toolbar = current_user.roles.include?(Role.find_by_name('Rollcall')) ? "rollcall" : "application"
    Rollcall::SchoolsController.app_toolbar toolbar

    schools = current_user.schools.sort_by{|school| school.display_name}
    @school = School.find(params[:id])

    if @school
      @district = @school.district
    end

    respond_to do |format|
      if @school && schools.include?(@school)
        format.html
        format.xml { render :xml => @school }
      else
        flash[:error] = "You do not have any schools or school does not exist"
        format.html
        format.xml { render :xml => "", :status => :unprocessable_entity }
      end
    end
  end
end
