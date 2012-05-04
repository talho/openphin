class Report::Report < ActiveRecord::Base

  self.table_name = "report_reports"

  include ActionView::Helpers::DateHelper

  belongs_to :author, :class_name => 'User'
  serialize :criteria

  has_many   :filters
  has_one    :dataset

  scope :expired, :conditions => ["created_at <= ?", 30.days.ago]
  scope :expiring_soon, :conditions => ["created_at <= ? and created_at > ?", 25.days.ago, 26.days.ago]
  scope :complete, :conditions => ['incomplete = ?', false]

  has_attached_file :rendering, :path => ":rails_root/reports/:rails_env/:id/:filename"
  
  validates_presence_of  :author
  validates_associated   :author
  validates_inclusion_of :incomplete, :in => [false,true]

  after_create :do_after_create
  before_destroy :do_before_destroy
  
  validate :on => :create do
    begin
      self[:recipe] = criteria["recipe"] unless recipe
      recipe.constantize
      self[:name] = recipe.demodulize.gsub(/([A-Z][a-z]+)/,'\1-').sub(/-$/,'')
    rescue NameError
      errors.add_to_base "a recipe class of #{recipe.nil? ? 'nil' : recipe.to_s} is not found on the system"
    end
  end

  def dataset
    @collection ||= REPORT_DB.collection(name.to_s)
  end

  def full_name
    "#{name}-#{id}"
  end

  def as_json(options={})
    json_columns = JSON_COLUMNS.map(&:to_sym)
    json = super(:only => json_columns)
    options[:inject].each {|key,value| json[key] = value} if options[:inject]
    json
  end

  def rendering_updated_at
    self[:rendering_updated_at] ? time_ago_in_words(self[:rendering_updated_at]) : "Generating...Click Refresh"
  end

  def do_after_create
    update_attribute(:name,"#{recipe.demodulize.gsub(/([A-Z][a-z]+)/,'\1-')}#{id}")
  end

  def to_csv
    # uses the view helpers just as the html templates would
    begin
      meta = dataset.find({:meta=>{:$exists=>true},:report_id=>id}).first["meta"]
      raise "Report #{name} is missing meta component" unless meta
      #     ex: [['name','Name'],['email','Email Address'],['role_requests','Pending Role Requests','to_rpt']]
      directives = meta["template_directives"]
      raise "Report #{name} is missing column directives" unless directives
      # setup supporting view
      helper_expected = directives.detect{|e| e.size > 2}
      if helper_expected
        view = ActionView::Base.new
        recipe_obj = recipe.constantize
        helpers = recipe_obj.respond_to?(:helpers) ? (recipe_obj.helpers || []) : []
        helpers.each {|h| view.extend(h.constantize)}
      end
      # generate csv
      headers = directives.collect{|col| col.first}
      raise "Report #{name} has malformed the csv header" unless headers.kind_of? Array
      entries = dataset.find({:i=>{:$exists=>true},:report_id=>id})
      csv = CSV.generate(:force_quotes=>true,:headers=>headers,:write_headers=>true) do |row|
        entries.each do |entry|
          rr = directives.inject([]) do |memo,column|
            memo << ( (column.size > 2) ? view.send(column[2],entry[column[0]]) : entry[column[0]] )
          end
          row << rr
        end
      end
      csv.empty? ? "\n" : csv
    rescue StandardError => error
      raise error
    end
  end

  private

  JSON_COLUMNS =  %w(id author_id rendering_file_name rendering_file_size rendering_updated_at dataset_size dataset_updated_at incomplete)

  def before_destroy
    dataset.remove("report_id"=>self[:id])
  end

end
