class Report::Report < ActiveRecord::Base

  # create_table :reports, :force => true do |t|
  #   t.integer   :author_id
  #   t.integer   :recipe_id
  #   
  #   t.string    :resultset_file_name
  #   t.string    :resultset_content_type
  #   t.integer   :resultset_file_size
  #   t.datetime  :resultset_updated_at
  #   
  #   t.string    :rendering_file_name
  #   t.string    :rendering_content_type
  #   t.integer   :rendering_file_size
  #   t.datetime  :rendering_updated_at
  #   
  #   t.timestamps
  # end
  
  set_table_name :report_reports

  include ActionView::Helpers::DateHelper

  belongs_to :author, :class_name => 'User'
  belongs_to :recipe, :class_name => 'Report::Recipe'
  belongs_to :audience

  has_many   :filters
  has_one    :dataset

  has_attached_file :resultset, :path => ":rails_root/reports/:rails_env/:id/:filename"
  has_attached_file :rendering, :path => ":rails_root/reports/:rails_env/:id/:filename"
  
  validates_presence_of     :author
  validates_presence_of     :recipe_id
  validates_inclusion_of    :incomplete, :in => [false,true]

  public

  def dataset
    @collection ||= REPORT_DB.collection(name)
  end

  def name
    # association reload on a STI will cause a ActiveRecord::SubclassNotFound Exception
    # https://rails.lighthouseapp.com/projects/8994/tickets/2389
    begin
    # force association reload
      recipe(true) ? "#{recipe.name}-#{id}" : "#{id}"
    rescue ActiveRecord::SubclassNotFound
      "#{recipe.name}-#{id}"
    end
  end

  JSON_COLUMNS =  %w(id author_id resultset_file_name resultset_file_size rendering_file_name rendering_file_size
    resultset_updated_at rendering_updated_at incomplete)

  def as_json(options={})
    json_columns = JSON_COLUMNS.map(&:to_sym)
    json = super(:only => json_columns)
    options[:inject].each {|key,value| json[key] = value} if options[:inject]
    json
  end

  protected

  def resultset_updated_at
    date = dataset.find_one().present? ? dataset.find_one()["created_at"] : nil
    date ? time_ago_in_words(date) : "Generating...Click Refresh"
  end

  def rendering_updated_at
    self[:rendering_updated_at] ? time_ago_in_words(self[:rendering_updated_at]) : "Generating...Click Refresh"
  end

  private

  def before_create
    self.write_attribute(:incomplete,true)
  end

  def before_destroy
    dataset.drop
  end

end
