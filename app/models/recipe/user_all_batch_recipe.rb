class Recipe::UserAllBatchRecipe < Recipe
  
  class << self

    def description  # recipe description
      "Report of all users with display_name, email and role/jurisdiction columns using batch processing"
    end

    def helpers
      ['RoleMembershipsHelper']
    end

    def template_path
      File.join('reports','show.html.erb')
    end

    def template_directives
      [['display_name','Name'],['email','Email Address'],['role_memberships','Roles','to_rpt']]
    end

    def current_user
      @current_user
    end

    def capture_to_db(report)
      @current_user = report.author
      data_set = report.dataset
      id = {:report_id => report.id}
      data_set.insert( id.merge( {:report=>{:created_at=>Time.now.utc}} ))
      data_set.insert( id.merge( {:meta=>{:template_directives=>template_directives}} ))
      index = 0
      User.find_each(:batch_size=>10000) do |u|
        begin
          doc = id.clone
          doc[:display_name] = u.display_name
          doc[:email] = u.email
          doc[:role_memberships] = u.role_memberships.map(&:as_hash)
          doc[:i] = index += 1
          data_set.insert(doc)
        rescue NoMethodError
          #skip illegitimate entry
        end
        data_set.create_index("i")
      end
    end

  end

end
  
  