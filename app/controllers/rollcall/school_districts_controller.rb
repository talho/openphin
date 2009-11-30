class Rollcall::SchoolDistrictsController < ApplicationController
  def school
    @district = current_user.school_districts.detect{|d| d.id.to_s==params[:id]}
    if @district.nil?
      flash[:notice] = "You do not have access to that school district."
      redirect_to rollcall_path
    else
      @school = @district.schools.find_by_id(params[:school][:id])
      redirect_to @school
    end

  end
end