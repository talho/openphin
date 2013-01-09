class ReportSchedulesController < ApplicationController
  respond_to :json

  def index
    respond_with(@report_schedules = ReportSchedule.where(user_id: current_user.id))
  end

  def show
    respond_with(@report_schedule = ReportSchedule.where(report_type: params[:id], user_id: current_user.id).first_or_create)
  end

  def create
    params[:report_schedule] ||= {}
    params[:report_schedule][:days_of_week] = Array.new(7).map.with_index{ |a, i| (params[:report_schedule][:days_of_week] || {})[i.to_s]}
    @report_schedule = ReportSchedule.new params[:report_schedule]
    @report_schedule.user = current_user

    @report_schedule.save

    respond_with(@report_schedule)
  end

  def update
    params[:report_schedule] ||= {}
    params[:report_schedule][:days_of_week] = Array.new(7).map.with_index{ |a, i| (params[:report_schedule][:days_of_week] || {})[i.to_s]}
    @report_schedule = ReportSchedule.where(report_type: params[:id], user_id: current_user.id).first_or_create
    @report_schedule.update_attributes params[:report_schedule]

    respond_with(@report_schedule)
  end
end
