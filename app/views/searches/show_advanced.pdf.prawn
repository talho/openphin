debugger
if @results.empty?
  pdf.text "No Results Found", :size => 30, :style => :bold
else
  pdf.text "User Search Export", :size => 30, :style => :bold
  users = @results.map do |user|
    [
      user.display_name,
      user.email,
      user.role_memberships.map{|rm| "#{rm.role.name} in #{rm.jurisdiction.name}"}.sort.join("\n")
    ]
  
  end
  pdf.table users, :border_style => :grid,
    :row_colors => ["FFFFFF","DDDDDD"],
    :headers => ["Name", "Email", "Role Assignments"]
end


  