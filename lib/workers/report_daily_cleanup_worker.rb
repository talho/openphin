class ReportDailyCleanupWorker < BackgrounDRb::MetaWorker
  set_worker_name :report_daily_cleanup_worker
  reload_on_schedule true

  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def clean(args=nil)
    Report::Report.expired.find_each(:batch_size=>100) do |report|
      report.destroy
    end
  end

end