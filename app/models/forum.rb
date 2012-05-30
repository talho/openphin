class Forum < ActiveRecord::Base
  after_save :update_lock_version

  has_many :comments, class_name: "Topic"
  
  has_many  :topics, 
            :conditions => {:comment_id => nil}, 
            :order => "#{Topic.table_name}.sticky desc, #{Topic.table_name}.created_at desc", 
            :dependent => :destroy
            
  accepts_nested_attributes_for :topics, 
            :reject_if => lambda { |a| a[:content].blank? }, 
            :allow_destroy => true   

  belongs_to :audience, :autosave => true
  has_many :users, :finder_sql => proc {"SELECT u.* 
                                   FROM users u 
                                   JOIN sp_recipients(#{self.audience_id}) r ON u.id = r.id"}
                                   
  has_many :subforums,  :class_name => 'Forum', :foreign_key => :parent_id,
                        :order => "created_at ASC",
                        :dependent => :destroy, :uniq => true
                        
                      
  belongs_to :owner,  :class_name => 'User', :foreign_key => :owner_id
  
  belongs_to :moderator_audience, :class_name => 'Audience', :foreign_key => :moderator_audience_id
  
  validate :validate_subforum, :on => :create
  validate :validate_subforum, :on => :update
  
  def self.for_user(user)
    user_id = user.class == User ? user.id : user
    user = user.class == User ? user : User.find(user)
    if user.is_super_admin?
      self.scoped
    else
      joins(send(:sanitize_sql_array, ["LEFT JOIN sp_audiences_for_user(?) au ON au.id = audience_id", user_id])).where("(owner_id = (?) or (au.id is not null and hidden_at is null))",user_id)
    end
  end
  
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }
  
  def audiences
    # audiences/_fields excepts an array for has_many relationship
    [audience]
  end
  
  accepts_nested_attributes_for :audience, 
            :allow_destroy => true   #destroy not necessary since forum deletion is not an option
            
  accepts_nested_attributes_for :moderator_audience,
            :allow_destroy => true              
  
   # required in helper, with Rails 2.3.5 :_destroy is preferred  
  #alias :_destroy :_delete unless respond_to? '_destroy'
  
  scope :recent, lambda{|limit| {:limit => limit, :order => "created_at DESC"}}


  # would like to DRY this up
  unhidden_lamb = lambda {|obj| obj.present? ? {:conditions => {:hidden_at => nil}} : {}}
  class << self
    def hide_conditions(obj)
      obj.present? ? {:conditions => {:hidden_at => nil}} : {}
    end
  end
  scope :unhidden, unhidden_lamb

  validates_presence_of  :name

  def hide=(hide_string)
    self.hidden_at = hide_string == "1" ? Time.now : nil 
  end
  
  def hide
    !self.hidden_at.nil?
  end

  def audience_attributes=(attributes)
    unless audience
      build_audience(attributes)
    else
      attributes.delete(:id)
      audience.update_attributes(attributes)
    end
  end

  def self.find_for(id,user)
    options = hide_conditions !user.is_super_admin?
    result = self.find(id,options)
    return result unless result
    unless result.kind_of?(Array)
      forum = self.accessible_to(result,user)
      return forum unless forum
      forum = self.find(id,options)
    else
      result.select{|f| self.accessible_to(f,user) }
      forum_ids = result.collect(&:id)
      forums = self.find(forum_ids,options)
    end
  end
  
  def self.paginate_for(id,user,page,per_page=10)
    options = hide_conditions !user.is_super_admin?
    result = self.find(id,options)
    return result unless result
    unless result.kind_of?(Array)
      forum = self.accessible_to(result,user)
      return forum unless forum
      forum = self.find(id,options)
    else
      result = result.select{|f| self.accessible_to(f,user) }
      forum_ids = result.collect(&:id)
      options[:page] = page
      options[:per_page] = per_page
      forums = self.paginate(forum_ids,options)
    end
  end
  
  def self.accessible_to(result,user)
    # if no audience is specified then this forum is open to anyone
    # if a audience is specified for this forum, am I in the audeience?
    if result.audience.nil?
      forum = result
    else
      forum = ( user.is_super_admin? || audience.has_user?(user) ) ? result : nil
    end
  end
  
  def topic_attributes=(attributes)
    topics << topics.build(attributes) 
  end
  
  def self.per_page
    # for paginate
    10
  end

  def to_s
    name
  end
  
  protected
    
  def validate_subforum
    if self.failed_child_forum_insertion?
      self.errors.add("parent_id", "If you are inserting or moving a subforum you can't insert a subforum to itself or it's children")
    elsif self.failed_subforum_depth_check?
      self.errors.add("parent_id", "If you are inserting or moving a subforum it must be less than 5 deep")    
    end
  end
  
  def failed_subforum_depth_check?
    if self.parent_id      
      child = ActiveRecord::Base.connection.select_all("select sp_forum_get_count_to_deepest_leaf(#{self.id}) as depth")
      parent = ActiveRecord::Base.connection.select_all("select sp_forum_get_count_to_root(#{self.parent_id}) as depth")
      return parent[0]['depth'].to_i + child[0]['depth'].to_i > 5
    end
    return false
  end
  
  def failed_child_forum_insertion?
    if self.parent_id
      result = ActiveRecord::Base.connection.select_all("select * from forums where id = #{self.parent_id} and #{self.parent_id} not in (select sp_get_children_forums_with_root(#{self.id}))")
      return result.count == 0
    end
    return false
  end

  private

  def update_lock_version
    # necessary in order to increment the lock_version for this forum
    Forum.update_counters self.id, {}
  end
  
end
