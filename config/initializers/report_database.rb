# REPORT_DB = Mongo::Connection.new("localhost",27017,:pool_size=>5,:timeout=>5).db("openphin_#{Rails.env}")

path_seed = File.dirname(__FILE__)
# path_seed =  "/Users/rich/rails/openphin/config/mongo_database.yml.example"
c_path =  path_seed.split(File::SEPARATOR)
c_path.pop
config_path = c_path.push("mongo_database.yml").join(File::SEPARATOR)

begin
  configs = YAML::load(File.read(config_path))
  if (config = configs[Rails.env])
    conn = Mongo::Connection.new(config["host"],config["port"],config)
    REPORT_DB = conn.db(config["database"])
    REPORT_DB.authenticate(config["username"],config["password"]) if config["password"]
  end
rescue Errno::ENOENT
  # no Reports menu without this REPORT_DB
end


