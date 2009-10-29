class Rollcall::SchoolsController < ApplicationController
  before_filter :rollcall_required

  def index
    toolbar = current_user.roles.include?(Role.find_by_name('Rollcall')) ? "rollcall" : "application"
    Rollcall::SchoolsController.app_toolbar toolbar

    schools = current_user.schools.sort_by{|school| school.display_name}

    if params["district"] && !params["district"][:id].blank? && (!params["school"] || params["school"][:id].blank?)
      @school = SchoolDistrict.find(params["district"][:id]).schools.first
    elsif params["school"] && !params["school"][:id].blank?
      @school = School.find(params["school"][:id])
    else
      @school = schools.first
    end

    if @school
      @district = @school.district

      params[:timespan]="7" if params[:timespan].blank?
      timespan=params[:timespan].to_i

      #labels should be 1:week if timespan is greater than 1 week
      if timespan > 7
        xlabels = ((1-timespan-Date.today.wday)..0).step(7).map{|d| (Date.today+d.days).strftime("%m-%d")}.join("|")
      else
        xlabels = ((1-timespan)..0).map{|d| (Date.today+d.days).strftime("%m-%d")}.join("|")
      end

      @school_chart=Gchart.line(:size => "600x400",
                                :title => "Recent Absenteeism",
                                :axis_with_labels => "x,y",
                                :axis_labels => xlabels,
                                :legend => @school.display_name,
                                :data => @school.absentee_reports.recent(7).map{|rep| (rep.absent.to_f / rep.enrolled.to_f).round(4)*100}.reverse,
                                :custom => "chdlp=b",
                                :encoding => "text"
      )
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

      params[:timespan]="7" if params[:timespan].blank?
      timespan=params[:timespan].to_i

      #labels should be 1:week if timespan is greater than 1 week
      if timespan > 7
        xlabels = ((1-timespan-Date.today.wday)..0).step(7).map{|d| (Date.today+d.days).strftime("%m-%d")}.join("|")
      else
        xlabels = ((1-timespan)..0).map{|d| (Date.today+d.days).strftime("%m-%d")}.join("|")
      end

      @school_chart=Gchart.line(:size => "600x400",
                                :title => "Recent Absenteeism",
                                :axis_with_labels => "x,y",
                                :axis_labels => xlabels,
                                :max => 30,
                                :legend => @school.display_name,
                                :data => @school.absentee_reports.recent(7).map{|rep| (rep.absent.to_f / rep.enrolled.to_f).round(4)*100}.reverse,
                                :custom => "chxr=1,0,30",
                                :encoding => "text",
                                :max_value => 30
      )
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
