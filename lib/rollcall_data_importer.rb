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

  def self.read_data(filename, field_separator=',', record_separator="\n")
    raise "Data file #{filename} does not exist." unless File.exist?(filename)

    datafile=File.open(filename)
    data = datafile.read.split(record_separator).map{|d| d.split(field_separator)}
    datafile.close
    return data
  end

  def self.import_schools(filename, errstream=STDERR)
    data = read_data(filename, "|")
    data[1..-1].each do |school|
      school_number, name, display_name, level, region = school
      school = School.find_by_display_name(display_name)
      if school.nil?
        errstream << "Could not find school #{display_name}"
        next
      end
      school.update_attributes(:name => name, :region => region, :school_number => school_number, :level => level)
      errstream << "Could not update school #{display_name}" unless school.save
    end
  end

  def self.historical_import(filename, errstream=STDERR)
    data = read_data(filename, "\t")
    badschools = []
    data[1..-1].each do |report|
      report_date, schoolname, enrolled, absent = report
      next if badschools.include?(schoolname)
      school=School.find_by_name(schoolname)
      if school.nil?
        errstream << "Could not find school #{schoolname}\n"
        badschools.push(schoolname)
        badschools.sort!{|a,b| a <=> b}
        next
      end
      absentee_report = school.absentee_reports.build(:report_date => Date.parse(report_date), :enrolled => enrolled, :absent => absent)
      unless absentee_report.valid?
        errstream << "Could not save absentee record: #{helper.error_messages_for(absentee_report)}\n"
      end
      absentee_report.save
      
    end
    puts badschools.join("\n")
  end

end