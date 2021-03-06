class Topic < ActiveRecord::Base
  
  belongs_to :forum
  
  belongs_to :poster, :class_name => 'User'

  has_many :comments, :class_name => 'Topic', :foreign_key => :comment_id, 
                      :order => "created_at ASC", 
                      :dependent => :destroy
  accepts_nested_attributes_for :comments, 
                      :reject_if => lambda { |a| a[:content].blank? }, 
                      :allow_destroy => true

  belongs_to :thread, :class_name => 'Topic', :foreign_key => :comment_id

  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  scope :recent, lambda{|limit| {:limit => limit, :order => "created_at DESC"}}
  
  scope :recent_topics, lambda{|limit| {
    :select => "topics.id, topics.forum_id, topics.comment_id, topics.sticky, topics.locked_at, topics.name, topics.content, 
                topics.poster_id, topics.created_at, topics.updated_at, topics.hidden_at, topics.lock_version, 
                COALESCE(MAX(c.created_at), topics.created_at) as sortable_created_at",  
    :joins => "left join topics c on topics.id = c.comment_id",
    :conditions => "topics.comment_id IS NULL",
    :group => "topics.id, topics.forum_id, topics.comment_id, topics.sticky, topics.locked_at, topics.name, topics.content, 
               topics.poster_id, topics.created_at, topics.updated_at, topics.hidden_at, topics.lock_version",
    :order => "sortable_created_at DESC",
    :limit => limit}}
  
  scope :unhidden, lambda {|obj| obj.present? ? {:conditions => {:hidden_at => nil}} : {}}

  validates_presence_of :poster_id, :forum_id, :name
  #before_save :sanitize_content # removing this because redcloth escapes outgoing html. If we switch to bbcode, we need this even less


   # required in helper, with Rails 2.3.5 :_destroy is preferred  
  #alias :_destroy :_delete unless respond_to? '_destroy'
    
  def locked=(lock_string)
    self.locked_at = lock_string == "1" ? Time.now : nil 
  end
  
  def locked?
    !self.locked_at.nil?
  end
  
  def hide=(hide_string)
    self.hidden_at = hide_string == "1" ? Time.now : nil 
 end
  
  def hide
    !self.hidden_at.nil?
  end

  def comment_attributes=(attributes)
    if attributes[:id]
      # allow for delete
      unless attributes[:_destroy].nil?
        Topic.destroy(attributes[:id])
      else
        Topic.update(attributes[:id], attributes)
      end
    else
      comments << comments.build(attributes)
    end
  end
  
  def dest_forum_id
    forum_id
  end

  def to_s
    name
  end

  private

  def sanitize_content
    self.content = self.content.gsub(/<\/?[^>]*>/, "") if self.content
  end
    
end


