class ReportsController < ApplicationController

  respond_to :json, :except => :show
  respond_to :html, :pdf, :only => :show

  layout 'report', :only => :show

  def index
    respond_with(@reports = current_user.reports)
  end

  def show
    respond_with(@report = Report.where(id: params[:id], user_id: current_user.id).first) do |format|
      format.any {render @report.view }
    end
  end

  def new
    @report_types = Report.subclasses.select{|r| r.run_detached? && r.user_can_run?(current_user.id)}
    respond_with(@report_types)
  end

  def create
    begin
      report_class = params[:report].constantize
      throw "You must select a report" unless report_class.superclass == Report
    rescue
      respond_with(@errors = {msg: "#{params[:report]} type not found."}) do |format|
        format.any { render 'application/failure', status: 404}
      end
      return
    end

    if report_class.user_can_run?(current_user.id)
      r = report_class.build_report(current_user.id)
      if r.save
        respond_with() do |format|
          format.any {render 'application/success'}
        end
      else
        respond_with(@errors = r.errors) do |format|
          format.any { render 'application/failure', status: 400}
        end
      end
    else
      respond_with(@errors = {msg: "User does not have permission to run #{params[:report]} type."}) do |format|
        format.any { render 'application/failure', status: 400}
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy
    @report = current_user.reports.find(params[:id]);

    if @report.nil?
      respond_with(@errors = {msg: "Report not found."}) do |format|
        format.any { render 'application/failure', status: 404}
      end
      return
    end

    if @report.destroy
      respond_with() do |format|
          format.any {render 'application/success'}
      end
    else
      respond_with(@errors = @report.errors) do |format|
        format.any { render 'application/failure', status: 404}
      end
    end
  end
end
