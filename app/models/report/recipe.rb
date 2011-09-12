class Report::Recipe < ActiveRecord::Base
  # create_table :report, :force => true do |t|
  require 'base32/crockford'

  set_table_name  :report_recipes
  has_many :reports, :class_name => 'Report::Report'
  belongs_to :audience
  named_scope :deployable, :conditions => "report_recipes.type <> 'Report::Recipe'"

  named_scope :authorized, lambda {|user|
    {:joins => "INNER JOIN audiences_recipients AS ar ON report_recipes.audience_id = ar.audience_id",
    :select => '*',
    :conditions => "ar.user_id = #{user[:id]}"
    }
  }

  def self.find_or_create
    self.find_or_create_by_type(self.name)
  end

  def after_create
    jurisdictions = [Jurisdiction.find_by_name("Dallas"),Jurisdiction.find_by_name("Potter")]
    aud = Audience.new( :roles=>[ Role.find_by_name("Medical Director")],:jurisdictions=>jurisdictions )
    aud.recipients(:force => true).length if aud # apply the recipients for the audience so that the mapped joins will actually work
    update_attribute(:audience,aud)
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

  def template_path
    File.join(Rails.root,'app','views','reports','report.html.erb')
  end

  def capture_to_db(report)
    now = Time.now.utc
    report.dataset.insert({"created_at"=>now})
    begin
      size = report.dataset.stats["size"]
    rescue Mongo::OperationFailure
      size = 0
    end
    report.update_attributes(:dataset_updated_at=>now,:dataset_size=>size)
  end

# Overwriteable Infrastructure
  def type_humanized
    self.class.name.demodulize.split(/(?=[A-Z])/).join(" ")
  end

  def generate_rendering_of_on_with( report, view, template, filters=nil )
   filtered_at = nil
   pre_where = {"i"=>{'$exists'=>true}}
   if filters.present?
     filtered_at = filters["filtered_at"]
     fa = filtered_at.nil? ? "" : "-#{filtered_at}"
     filename = "#{report.name}#{fa}.html"
     where_filter = filters_for_query(filters["elements"])
     where = pre_where.merge(where_filter)
   else
     filename = "#{report.name}.html"
     where = pre_where
   end
   results = []
   report.dataset.find(where).each{|e| results << e}
   Dir.mktmpdir do |dir|
     path = File.join dir, filename
     File.open(path, 'wb') do |f|
       rendering = view.render(:inline=>template,:type=>'html',:locals=>{:results=>results,:filters=>filters})
       f.write(rendering)
     end
     report.update_attributes( :rendering=>File.new(path, "rb"), :incomplete=>false )
   end
  end

  def filters_for_query(filters)
    # [{"display_name"=>"Bob Dole"}, {"email"=>"jason@example.com"}, {"i"=>{"minValue"=>25, "maxValue"=>54}}]
    f = filters.inject({}) do |res,item|
      if item.kind_of? Hash
        key = item.keys.first
        if item[key].kind_of? Hash
          res[key] = {'$gte' => item[key]["minValue"], '$lte' => item[key]["maxValue"]}
        else
          value = item[key]
          res[key] = { '$in' => (value.kind_of? Array) ? value : [value] }
        end
      end
      res
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
         klass = "#{self.name.split('::').first}::#{class_name}"
         klass.constantize.create unless Report::Recipe.find_by_type(klass)
       rescue ActiveRecord::StatementInvalid => e
         puts "Missing table, need to migrate (#{e})"
       rescue ActiveRecord::AssociationTypeMismatch => e
         # the recipe audience Jurisdiction and Role may not be defined during test
         raise unless ["test","cucumber"].include?(Rails.env)
       end
     end
   end
  end

  JSON_COLUMNS =  %w(id type_humanized description)

  def as_json(options={})
   json_columns = JSON_COLUMNS.map(&:to_sym)
   json = super(:only => json_columns)
   options[:inject].each {|key,value| json[key] = value} if options[:inject]
   json
  end

end

