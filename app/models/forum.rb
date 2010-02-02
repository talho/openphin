class Forum < ActiveRecord::Base
    
  default_scope :conditions => {:hidden_at => nil}

  has_many  :topics, 
            :conditions => {:comment_id => nil}, 
            :order => "#{Topic.table_name}.sticky desc, #{Topic.table_name}.updated_at desc", 
            :dependent => :destroy
  accepts_nested_attributes_for :topics, 
            :reject_if => lambda { |a| a[:content].blank? }, 
            :allow_destroy => true   

  has_one   :audience, :autosave => true
  accepts_nested_attributes_for :audience, 
            :allow_destroy => true   #destroy not necessary since forum deletion is not an option
  
   # required in helper, with Rails 2.3.5 :_destroy is preferred  
  alias :_destroy :_delete unless respond_to? '_destroy'

  named_scope :recent, lambda{|limit| {:limit => limit, :order => "created_at DESC"}}
  named_scope :distinct_poster, :group => :poster_id

  validates_presence_of  :name


  def hide=(hide_string)
    self.hidden_at = hide_string == "1" ? Time.now : nil 
  end
  
  def hide
    !self.hidden_at.nil?
  end

  def audience_attributes=(attributes)
    build_audience(attributes)
  end
  
  def self.visible_to(user)
    user.is_super_admin? ? Forum.with_exclusive_scope { Forum.all } : Forum.all
  end
    
  def accessible_to(user)
    return self if !audience || user.is_super_admin?
    audience.recipients.include?(user) ? self : nil
  end
  
  def self.accessible_by(forums,user)
    forums.select{ |f|
#      next unless f.respond_to?('accessible_to')
      f.accessible_to(user)
    }
  end
  
  def topics_attributes=(attributes)
    # parses the topic attributes hash built by FormBuilder
    topics << topics.build(attributes) 
    # if attributes.kind_of? Array
    #   # a topics to be built and appended to topics collection
    #   attributes.first.delete("_destroy")
    #   topics << topics.build(attributes.first) 
    # else
    #   if value.kind_of?(Hash)  && key.kind_of?(String)  && !(key =~ /\D+/)
    #     attributes.each do |key,value|
    #       # a hash of topic hashes with the key is the index into the topics collection
    #       next unless (0..(topics.count-1)).include?(index = key.to_i) 
    #       topic = Topic.find topics[index].id
    #       value.each{|ckey,cvalue| topic.update_attribute(ckey,cvalue)}
    #     end
    #   end
    # end
  end
  
end
