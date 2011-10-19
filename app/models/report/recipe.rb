class Report::Recipe < ActiveRecord::Base
  # create_table :report, :force => true do |t|
  require 'base32/crockford'

  set_table_name  :report_recipes
  has_many :reports, :class_name => 'Report::Report'
  belongs_to :audience
  named_scope :deployable, :conditions => "report_recipes.type <> 'Report::Recipe'"
  attr_accessor :report_options

  named_scope :authorized, lambda {|user|
    {:joins => "INNER JOIN audiences_recipients AS ar ON report_recipes.audience_id = ar.audience_id",
    :select => '*',
    :conditions => "ar.user_id = #{user[:id]}"
    }
  }

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

# vvvvvvvvv Overwriteable Infrastructure below vvvvvvvvvv

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
       rendering = view.render(:inline=>template,:type=>'html',:locals=>{:results=>results,:filters=>filters}, :layout=>"report/layouts/report")
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

  JSON_COLUMNS =  %w(id type_humanized description)

  def as_json(options={})
   json_columns = JSON_COLUMNS.map(&:to_sym)
   json = super(:only => json_columns)
   options[:inject].each {|key,value| json[key] = value} if options[:inject]
   json
  end

private

  def self.register
    return unless Report::Recipe.find_by_type(nil).registered_at.nil?
    # delete perished recipes
    present = "'"+send(:subclasses).reject{|s| !s.name.end_with? 'Recipe'}.map(&:name).join("','")+"'"
    puts "vvvv keep during delete vvvvvvv"
    puts present
    puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    connection.delete( "delete from #{table_name} where type not in (#{present})" )
    # recreate recipes that have changed
    report_path = File.dirname(__FILE__)
    Report::Recipe.deployable.all.each do |recreatee|
      filename = File.join(report_path,recreatee.name.underscore+'.rb')
      if ( File.mtime(filename) > recreatee.created_at)
        puts "vvvvvvvv recreate vvv"
        puts recreatee.name
        puts "^^^^^^^^^^^^^^^^^^^"
        recreatee.destroy
        recreatee.name.constantize.create
      end
    end
    # install new recipes
    present = send(:subclasses).reject{|s| !s.name.end_with? 'Recipe'}.map(&:name)
    present.each do |klass|
      unless find_by_type(klass)
        klass.constantize.create
        puts "vvvvvvvv install vvv"
        puts klass
        puts "^^^^^^^^^^^^^^^^^^^"
      end
    end
    Report::Recipe.find_by_type(nil).update_attribute(:registered_at,Time.now)
  end

end

