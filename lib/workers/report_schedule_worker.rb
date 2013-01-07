class ReportScheduleWorker < BackgrounDRb::MetaWorker
  set_worker_name :report_schedule_worker
  reload_on_schedule true

  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def run(args = nil)
    schedules = ReportSchedule.where("days_of_week[?] = 't'", Date.today.wday + 1) # Don't ask me why, but postgres is 1-indexed
    schedules.each do |sched|
      r = sched.report_type.constantize.build_report(sched.user_id)
      r.save!
      ReportMailer.report_generated(r).deliver
    end
  end
end
