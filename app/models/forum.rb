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
  def audiences
    # audiences/_fields excepts an array for has_many relationship
    [audience]
  end
  
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
      
  def self.find_for(id,user)
    # can I see the hidden forums?
    result = user.is_super_admin? ? self.with_exclusive_scope { self.find(id) } : self.find(id)
    return result unless result
    unless result.kind_of?(Array)
      forum = self.accessible_to(result,user)
      return forum unless forum
      forum = user.is_super_admin? ? self.with_exclusive_scope { self.find(forum.id) } : self.find(forum.id)
    else
      result.select{|f| self.accessible_to(f,user) }
      forum_ids = result.collect(&:id)
      forums = user.is_super_admin? ? self.with_exclusive_scope { self.find(forum_ids) } : self.find(forum_ids)
    end
  end
  
  def self.paginate_for(id,user,page)
    # can I see the hidden forums?
    result = user.is_super_admin? ? self.with_exclusive_scope { self.find(id) } : self.find(id)
    return result unless result
    unless result.kind_of?(Array)
      forum = self.accessible_to(result,user)
      return forum unless forum
      forum = user.is_super_admin? ? self.with_exclusive_scope { self.find(forum.id) } : self.find(forum.id)
    else
      result.select{|f| self.accessible_to(f,user) }
      forum_ids = result.collect(&:id)
      forums = user.is_super_admin? ? self.with_exclusive_scope { self.paginate(forum_ids,:page => page) } : self.paginate(forum_ids,:page => page)
    end
  end
  
  def self.accessible_to(result,user)
    # if no audience is specified then this forum is open to anyone
    # if a audience is specified for this forum, am I in the audeience?
    unless (audience = result.audience)
      forum = result
    else
      forum = ( audience.owner == user || audience.recipients(:include_public=>false).include?(user) ) ? result : nil
    end
  end
  
  def topic_attributes=(attributes)
    topics << topics.build(attributes) 
  end
  
  def self.per_page
    # for paginate
    5
  end
  
end
