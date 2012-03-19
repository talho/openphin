class Recipe < ActiveRecord::Base

  require 'base32/crockford'  # for naming the filtered file

  extend RecipeModules::Base

protected

  def self.generate_rendering( report, view, template, filters=nil )
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
   subject = report.dataset.find({:report=>{:$exists=>true}}).first['report']
   results = []
   report.dataset.find(where).each{|e| results << e}
   Dir.mktmpdir do |dir|
     path = File.join dir, filename
     File.open(path, 'wb') do |f|
       rendering = view.render(:inline=>template,:type=>'html',
                               :locals=>{:entries=>results,
                                         :report=>subject,
                                         :filters=>filters},
                               :layout=>layout_path)
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

end

