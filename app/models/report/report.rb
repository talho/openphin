class Report::Report < ActiveRecord::Base

#  create_table "report_reports", :force => true do |t|
#    t.integer  "author_id"
#    t.boolean  "incomplete"
#    t.string   "rendering_file_name"
#    t.string   "rendering_content_type"
#    t.integer  "rendering_file_size"
#    t.datetime "rendering_updated_at"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.integer  "audience"
#    t.integer  "recipe_id"
#    t.string   "name"
#    t.integer  "dataset_size"
#    t.datetime "dataset_updated_at"
#  end
  
  set_table_name :report_reports

  include ActionView::Helpers::DateHelper

  belongs_to :author, :class_name => 'User'
  belongs_to :recipe, :class_name => 'Report::Recipe'
  belongs_to :audience, :class_name => 'Audience'

  has_many   :filters
  has_one    :dataset

  has_attached_file :rendering, :path => ":rails_root/reports/:rails_env/:id/:filename"
  
  validates_presence_of     :author
  validates_presence_of     :recipe_id
  validates_inclusion_of    :incomplete, :in => [false,true]

  named_scope :expired, :conditions => ["created_at <= ?", 30.days.ago]
  named_scope :expiring_soon, :conditions => ["created_at <= ? and created_at > ?", 25.days.ago, 26.days.ago]
  named_scope :complete, :conditions => ['incomplete = ?', false]

  public

  def dataset
    @collection ||= REPORT_DB.collection(name)
  end

  JSON_COLUMNS =  %w(id author_id rendering_file_name rendering_file_size rendering_updated_at dataset_size dataset_updated_at incomplete)

  def as_json(options={})
    json_columns = JSON_COLUMNS.map(&:to_sym)
    json = super(:only => json_columns)
    options[:inject].each {|key,value| json[key] = value} if options[:inject]
    json
  end

#  def dataset_updated_at
#    date = dataset.find_one().present? ? dataset.find_one()["created_at"] : nil
#    date ? time_ago_in_words(date) : "Generating...Click Refresh"
#  end
#
#  protected

  def rendering_updated_at
    self[:rendering_updated_at] ? time_ago_in_words(self[:rendering_updated_at]) : "Generating...Click Refresh"
  end

  def after_create
    update_attribute(:name,"#{recipe.name}-#{id}")
  end

  def before_destroy
    dataset.drop
  end

end
