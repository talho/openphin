class Report::Recipe < ActiveRecord::Base

  set_table_name :report_recipes
  require 'base32/crockford'  # for naming the filtered file

  class << self

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

  end

protected

  def self.generate_rendering_of_on_with( report, view, template, filters=nil )
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

  def self.filters_for_query(filters)
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

  def self.all
    send(:subclasses).reject{|s| !s.name.end_with? 'Recipe'}.map(&:name)
  end

  def self.find(param)
    begin
      param.constantize
    rescue
       raise ActiveRecord::RecordNotFound
    end
  end

private

  def self.as_json(options={})
    {:id=>name,:description=>description}
  end

  def self.humanized(name)
    name.demodulize.split(/(?=[A-Z])/).join(" ")
  end

end

