class Topic < ActiveRecord::Base
  
  belongs_to :forum
  
  belongs_to :poster, :class_name => 'User'

  has_many :comments, :class_name => 'Topic', :foreign_key => :comment_id, 
                      :order => "created_at ASC", 
                      :dependent => :destroy
  accepts_nested_attributes_for :comments, 
                      :reject_if => lambda { |a| a[:content].blank? }, 
                      :allow_destroy => true
  
  named_scope :recent, lambda{|limit| {:limit => limit, :order => "created_at DESC"}}
  named_scope :distinct_poster, :group => :poster_id
  

  validates_presence_of :poster_id, :forum_id, :name

   # required in helper, with Rails 2.3.5 :_destroy is preferred  
  alias :_destroy :_delete unless respond_to? '_destroy'
    
  def locked=(lock_string)
    self.locked_at = lock_string == "1" ? Time.now : nil 
  end
  
  def locked?
    !self.locked_at.nil?
  end
  
  def comment_attributes=(attributes)
    comments << comments.build(attributes)
  end
    
end


