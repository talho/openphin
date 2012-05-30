# REPORT_DB = Mongo::Connection.new("localhost",27017,:pool_size=>5,:timeout=>5).db("openphin_#{Rails.env}")

config_path = File.join(Rails.root,'config','mongo_database.yml')
begin
  configs = YAML::load(File.read(config_path)).with_indifferent_access
  if (config = configs[Rails.env])
    conn = Mongo::Connection.new(config[:host],config[:port],config[:options].symbolize_keys)
    REPORT_DB = conn.db(config[:database])
    REPORT_DB.authenticate(config[:database],config[:password]) if config[:password]
  else
    puts "REPORT_DB has not been initialized"
  end
rescue Errno::ENOENT
  # no Reports menu without this REPORT_DB
end


