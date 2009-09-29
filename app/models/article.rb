class Article < ActiveRecord::Base
	belongs_to :author, :class_name => "User"
	named_scope :recent, :limit => 3, :order => "pub_date desc"
end
