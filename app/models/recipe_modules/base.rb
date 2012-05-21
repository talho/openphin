module RecipeModules
  module Base

    def description
      "Base Recipe that creates the recipe infrastructure including defaults.  Supports unit test with using defaults."
    end

    def helpers
      []
    end

    def template_path
      File.join('reports','show.html.erb')
    end

    def layout_path
      File.join("reports","layouts","report")
    end

    def template_directives
      [['display_name','Name'],['email','Email Address'],['role_memberships','Roles','to_rpt']]
    end

    def current_user
      @current_user
    end

    def capture_to_db(report)
      @current_user = report.author
      now = Time.now.utc
      report.dataset.insert({:report=>{:created_at=>now}})
      report.dataset.insert( {:meta=>{:template_directives=>template_directives}}.as_json )
      begin
        size = report.dataset.stats["size"]
      rescue Mongo::OperationFailure
        size = 0
      end
      report.update_attributes(:dataset_updated_at=>now,:dataset_size=>size)
    end

    def find(param)
      begin
        param.constantize
      rescue
         raise ActiveRecord::RecordNotFound
      end
    end

    def destroy
      # purposely do nothing
    end

    def as_json(options={})
      {:id=>name,:description=>description}
    end

    def humanized(name)
      name ||= ''
      name.demodulize.split(/(?=[A-Z])/).join(" ")
    end

    def recipe_names
      if Rails.env == 'development'
        pathname = File.join('app','models',name.underscore)
        glob_script = File.join(Rails.root,pathname,'**','*_recipe.rb')
        recipe_names = Dir.glob(glob_script).collect{|f| File.join(Rails.root,pathname,File.basename(f,'.rb'))}
        begin
          recipe_names.each{|n| require n}
#          puts "\n======recipe_names requires\n #{recipe_names}\n"
        rescue StandardError => e
          puts e
        end
      end
      descendants.map(&:name).select{|n| /^#{name}::/.match(n)}
    end

    def generate_rendering( report, view, template, filters=nil )
      filtered_at = nil
      pre_where = {"i"=>{'$exists'=>true},:report_id=>report.id}
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
      subject = report.dataset.find({:report=>{:$exists=>true},:report_id=>report.id}).first['report']
      results = report.dataset.find(where).to_a
      Dir.mktmpdir do |dir|
        path = File.join dir, filename
        File.open(path, 'wb') do |f|
          rendering = view.render(:file=>template,
                                  :locals=>{:entries=>results,
                                            :report=>subject,
                                            :filters=>filters},
                                  :layout=>layout_path)
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

  end
end