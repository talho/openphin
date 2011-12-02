class Report::UserAllBatchRecipe < Report::Recipe
  
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
      data_set.insert({:report=>{:created_at=>Time.now.utc}})
      data_set.insert( {:meta=>{:template_directives=>template_directives}}.as_json )
      i = 1
      User.find_each(:batch_size=>10000) do |u|
        doc = {"i"=>i,"display_name"=>u.display_name,"email"=>u.email,"role_memberships"=>u.role_memberships.map(&:as_hash)}
        data_set.insert(doc)
        i = i + 1
      end
      data_set.create_index("i")
    end

  end

end
  
  