class Report::UserAllRecipe < Report::Recipe

  # create_table :report, :force => true do |t|
  #   t.string    :type
  #   t.integer   :author_id  
  #   
  #   t.timestamps
  # end

  def description
    "Report of all users with their display_name, email and role/jurisdiction columns"
  end
  
  def helpers
    ['RoleMembershipsHelper']
  end
  
  def template_path
    File.join(Rails.root,'app','views','reports','show.html.erb')
  end

  def capture_to_db(report)
    dataset = report.dataset
    dataset.insert({"created_at"=>Time.now.utc})
    User.all.each_with_index do |u,i|
      doc = Hash["i",i+1,"display_name",u.display_name,"email",u.email,"role_memberships",
        u.role_memberships.map(&:as_hash)]
      dataset.insert(doc)
    end
    dataset.create_index("i")
  end

end
  
  
