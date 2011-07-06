class Report::UserAllBatchRecipe < Report::Recipe
  
  # create_table :report, :force => true do |t|
  #   t.string    :type
  #   t.integer   :author_id  
  #   
  #   t.timestamps
  # end

  def description  # recipe description
    "Report of all users with display_name, email and role/jurisdiction columns using batch processing"
  end
  
  def helpers
    ['RoleMembershipsHelper']
  end
  
  def template_path
    File.join(Rails.root,'app','views','reports','show.html.erb')
  end
  
  def capture_to(file)
    file.write( "# #{Time.now.to_formatted_s(:db)} recipe is #{self.class.name}".to_yaml)
    User.find_each(:batch_size=>10000) do |u|
      rec = Hash["display_name",u.display_name,"email",u.email,"role_memberships", u.role_memberships.map(&:as_hash)]
      file.write(rec.to_yaml)
    end
  end


end
  
  