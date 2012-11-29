class Report < ActiveRecord::Base
  attr_accessible :type, :user_id
  
  attr_accessor :params
  
  after_initialize :load_params_from_mongo
  
  after_create :create_mongo_entry
  
  after_update :update_mongo_entry
  
  before_destroy :destroy_mongo_entry
        
  def self.build_report(user_id, params)
    r = self.new user_id: user_id
    r.params = params
    r
  end
  
  protected
  
  def collection
    @collection ||= REPORT_DB.collection('reports')
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
