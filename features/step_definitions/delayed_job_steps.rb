When "delayed jobs are processed" do
  #We don't need this anymore, delayed job delays can be turned off
  #success, failures = Delayed::Worker.new.work_off
  #unless failures.zero?
  #  Delayed::Job.all.each {|j| puts j.last_error }
  #  raise "DelayedJob Error: #{failures.size} jobs failed" 
  #end
end
