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

    def capture_to_db(report)
      dataset = report.dataset
      dataset.insert({"created_at"=>Time.now.utc})
      i = 1
      User.find_each(:batch_size=>10000) do |u|
        doc = Hash["i",i,"display_name",u.display_name,"email",u.email,"role_memberships",
          u.role_memberships.map(&:as_hash)]
        dataset.insert(doc)
        i = i + 1
      end
      dataset.create_index("i")
    end

  end

end
  
  