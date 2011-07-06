class Report::UserFirstHundredRecipe < Report::Recipe

  # create_table :report, :force => true do |t|
  #   t.string    :type
  #   t.integer   :author_id  
  #   
  #   t.timestamps
  # end

  def description  # recipe description
    "Report of the first 100 users with display_name, email and role/jurisdiction columns"
  end
  
  def helpers
    ['RoleMembershipsHelper']
  end
  
  def template_path
    File.join(Rails.root,'app','views','reports','show.html.erb')
  end

  def capture_to(file)
    file.write( "# #{Time.now.to_formatted_s(:db)} recipe is #{self.class.name}".to_yaml)
    User.find(:all,:limit=>100).each do |u|
      rec = Hash["display_name",u.display_name,"email",u.email,"role_memberships",
        u.role_memberships.map(&:as_hash)]
      file.write(rec.to_yaml)
    end
  end

end
  
  