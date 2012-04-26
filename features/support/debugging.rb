After('@leave_the_window_open') do |scenario|
  if scenario.respond_to?(:status) && scenario.status == :failed
    print "Step Failed. Press Return to close browser"
    STDIN.getc
  end
end

AfterStep('@slow_motion') do |scenario|
  sleep 2
end

AfterStep('@single_step') do
  print "Single Stepping. Hit enter to continue"
  STDIN.getc
end

AfterStep('@pause') do
  print "Press Return to continue..."
  STDIN.getc
end

After('@clear_report_db') do
  REPORT_DB.collection_names.grep(/Recipe/){|c| REPORT_DB.drop_collection(c)}
end
