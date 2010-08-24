When "delayed jobs are processed" do
  success, failures = Delayed::Job.work_off
  unless failures.zero?
    Delayed::Job.all.each {|j| puts j.last_error }
    raise "DelayedJob Error: #{failures.size} jobs failed" 
  end
end
