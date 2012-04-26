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
        recipe_names = Dir.glob(glob_script).collect{|f| File.join(Rails.root,pathname,File.basename(f))}
        begin
          recipe_names.each{|n| require n}
          puts recipe_names
        rescue StandardError => e
          puts e
        end
      end
      subclasses.map(&:name).select{|n| /^#{name}::/.match(n)}
    end

  end
end