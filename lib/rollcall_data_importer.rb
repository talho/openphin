class RollcallDataImporter
  def self.process_uploads
    pickup_dir=File.join(File.dirname(__FILE__), "..", "tmp", "rollcall")
    Dir.ensure_exists(pickup_dir)
    Dir.ensure_exists(File.join(pickup_dir, "archive"))

    if File.exist?(pickup_dir)
      Dir[File.join(pickup_dir, "Attendance_*")].each do |file|
        ROLLCALL_LOGGER.warn("Opening file #{file}")
        import=File.open(file, "r")
        data=import.read.split("\n")
        import.close
        data.map!{|d| d.split("\t")}
        data.each do |rec|
          begin
            report_date, school, enrolled, absent = rec
            report_date=Date.parse(report_date)
            school=School.find_by_display_name(school.strip)
            if school
              AbsenteeReport.create(:school => school, :report_date => report_date, :enrolled => enrolled, :absent => absent)
            else
              puts "Could not find school named #{rec[1].strip}"
            end

          rescue
            ROLLCALL_LOGGER.error("Import failed for record: #{data.join("|")}; file:#{file}")
            next
          end
        end
        FileUtils.mv(file, File.join(File.dirname(file), "archive"))
      end
    end
  end
end