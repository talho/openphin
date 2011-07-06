class Report::Recipe < ActiveRecord::Base
  # create_table :report, :force => true do |t|

  set_table_name  :report_recipes
  has_many :reports, :class_name => 'Report::Report'
  named_scope :deployable, :conditions => "report_recipes.type <> 'Report::Recipe'"

  validates_presence_of     :type
  validates_uniqueness_of   :type

  def self.find_or_create
    self.find_or_create_by_type(self.name)
  end

  def name
    self[:type].demodulize.split(/(?=[A-Z])/).join("-")
  end

  def description
    "Base Recipe that creates the recipe infrastructure including defaults.  Supports unit test with using defaults."
  end
  
  def helpers
    []
  end

  def audience
    nil
  end
  
  def template_path
    File.join(Rails.root,'app','views','reports','report.html.erb')
  end

  def capture_to(file)
    file.write( {"display_name"=>"User101 FactoryUser"}.to_yaml )
  end

# Overwriteable Infrastructure
  def type_humanized
    self.class.name.demodulize.split(/(?=[A-Z])/).join(" ")
  end

  def capture_resultset_of( report, dir_override=nil )
     Dir.mktmpdir do |dir|
       filename = "#{report.name}.yml"
       path = File.join( dir_override || dir, filename )
       File.open(path, 'wb') { |file| capture_to file }
       report.update_attribute( :resultset, File.new(path, "rb") )
     end
   end

   def generate_rendering_of_on_with( report, view, template )
     filename = "#{report.name}.html"
     results = []
     YAML::load_documents(File.read(report.resultset.path)) { |record| results << record }
     Dir.mktmpdir do |dir|
       path = File.join dir, filename
       File.open(path, 'wb') do |f|
         rendering = view.render(:inline=>template,:type=>'html',:locals=>{:results=>results})
         f.write(rendering)
       end
       report.update_attributes( :rendering=>File.new(path, "rb"), :incomplete=>false )
     end
   end

  def bind_attributes(report)
    report.update_attribute(:audience,audience) if audience
  end

   def self.register_recipes
     # create Recipe models without loading them, enabling Reports to refer to
     report_path = File.dirname(__FILE__)
     Dir.glob(File.join(report_path,"**","*.rb")).each do |m|
       class_name = m.sub(report_path + File::SEPARATOR, '').sub(/\.rb$/, '').camelize
       if class_name.end_with? 'Recipe'
         begin
           find_or_create_by_type "#{self.name.split('::').first}::#{class_name}"
         rescue ActiveRecord::StatementInvalid => e
           puts "Missing table, need to migrate (#{e})"
         end
       end
     end
   end

   JSON_COLUMNS =  %w(id type type_humanized description)

   def as_json(options={})
     json_columns = JSON_COLUMNS.map(&:to_sym)
     json = super(:only => json_columns)
     options[:inject].each {|key,value| json[key] = value} if options[:inject]
     json
   end

 end

