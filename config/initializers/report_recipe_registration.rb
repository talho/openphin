# cleanse the recipe table for models that have been removed from the code base
Report::Recipe.find_by_sql("select id, audience_id from report_recipes").each do |recipe|
  begin
    Report::Recipe.find(recipe[:id])
  rescue ActiveRecord::SubclassNotFound
    Report::Recipe.delete(recipe[:id])
  end
end

# register recipe class models
report_path = File.join(Rails.root,"app","models","report")
Dir.glob(File.join(report_path,"**","*_recipe.rb")).each do |m|
  class_name = m[m.rindex("/")+1,m.length].sub(/\.rb$/,'').camelize
  if class_name.end_with? 'Recipe'
    begin
      klass  = "Report::#{class_name}"
      recipe = Report::Recipe.find_by_type(klass)
      if recipe.nil?
        klass.constantize.create
      elsif ( File.mtime(m) > recipe.created_at )
        # recreate recipe model since its code has been update
        recipe.destroy
        klass.constantize.create
      end
    rescue ActiveRecord::StatementInvalid => e
      puts "Missing table, need to migrate (#{e})"
    rescue ActiveRecord::AssociationTypeMismatch => e
      # the recipe audience Jurisdiction and Role may not be defined during test
      raise unless ["test","cucumber"].include?(Rails.env)
    end
  end
end
