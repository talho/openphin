class SchoolsController < ApplicationController
  app_toolbar "rollcall"

  def index
    schools = current_user.schools.sort_by{|school| school.display_name}

    if params["district"] && !params["district"][:id].blank? && (!params["school"] || params["school"][:id].blank?)
      @school = SchoolDistrict.find(params["district"][:id]).schools.first
    elsif params["school"] && !params["school"][:id].blank?
      @school = School.find(params["school"][:id])
    else
      @school = schools.first
    end

    if @school
      @prev_school = schools[schools.index(@school) - 1] unless schools.index(@school) - 1 < 0
      @next_school = schools[schools.index(@school) + 1]
      @district = @school.district
    end

    respond_to do |format|
      if @school && schools.include?(@school)
        format.html
        format.xml  { render :xml => @school }
      else
        flash[:error] = "You do not have any schools"
        format.html
        format.xml  { render :xml => "", :status => :unprocessable_entity }
      end
    end
  end

  def show
    schools = current_user.schools.sort_by{|school| school.display_name}

    if params["district"] && !params["district"][:id].blank? && (!params["school"] || params["school"][:id].blank?)
      @school = SchoolDistrict.find(params["district"][:id]).schools.first
    elsif params[:id]
      @school = School.find(params[:id])
    elsif params["school"] && !params["school"][:id].blank?
      @school = School.find(params["school"][:id])
    else
      @school = schools.first
    end

    if @school
      @prev_school = schools[schools.index(@school) - 1] unless schools.index(@school) - 1 < 0
      @next_school = schools[schools.index(@school) + 1]
      @district = @school.district
    end

    respond_to do |format|
      if @school && schools.include?(@school)
        format.html
        format.xml  { render :xml => @school }
      else
        flash[:error] = "You do not have any schools or school does not exist"
        format.html
        format.xml  { render :xml => "", :status => :unprocessable_entity }
      end
    end
  end
end
