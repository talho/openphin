class Report < ActiveRecord::Base
  class_attribute :view, :run_detached

  self.run_detached = false
  @@db_config = YAML::load(File.read(File.join(Rails.root,'config','mongo_database.yml')))[Rails.env]

  attr_accessible :type, :user_id

  attr_accessor :params

  belongs_to :user

  after_initialize :load_params_from_mongo

  after_create :create_mongo_entry

  after_update :update_mongo_entry

  before_destroy :destroy_mongo_entry

  def self.build_report(user_id, params)
    r = self.new user_id: user_id
    r.params = params
    r
  end

  def self.user_can_run?(user_id)
    true
  end

  protected

  def report_db
    config = @@db_config.symbolize_keys
    conn = Mongo::Connection.new(config[:host],config[:port],(config[:options]||{}))
    db = conn.db(config[:database])
    db.authenticate(config[:database],config[:password]) if config[:password]

    db
  end

  def collection
    @collection ||= report_db.collection('reports')
  end

  def load_params_from_mongo
    rec = collection.find_one({report_id: self.id})
    self.params = rec["params"] unless rec.nil?
  end

  def create_mongo_entry
    collection.save(report_id: self.id, params: params)
  end

  def update_mongo_entry
    collection.update({report_id: self.id}, {"$set" => {params: params}})
  end

  def destroy_mongo_entry
    collection.remove(report_id: self.id)
  end
end
