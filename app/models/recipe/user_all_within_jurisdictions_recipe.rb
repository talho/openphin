class Recipe::UserAllWithinJurisdictionsRecipe < Recipe

  # create_table :report, :force => true do |t|
  #   t.string    :type
  #   t.integer   :author_id  
  #   
  #   t.timestamps
  # end

  class << self
    include SearchModules::Search

    def description
      "Report of all users within the author's jurisdictions with their display_name, email and role/jurisdiction columns"
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
      if report.criteria.present?
        normalize_search_params(report.criteria)
        report.criteria['per_page'] = 1000   # max return set in config
        users = User.search(report.criteria)
      else
        users = User.where(report.author.within_jurisdictions).includes([:jurisdictions]).limit(1000).all
      end
      users.each_with_index do |u,i|
        doc = {"i"=>i+1,"display_name"=>u.display_name,"email"=>u.email,"role_memberships"=>u.role_memberships.map(&:as_hash)}
        data_set.insert(doc)
      end
      
      data_set.create_index("i")
    end

  end

end
  
  
