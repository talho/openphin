pdf.text "Group Recipient Export", :size => 30, :style => :bold
pdf.text "For Group: #{@group.name}", :size => 25, :style => :bold

users = @group.recipients.sort_by(&:display_name).map do |user|
  [
    user.display_name,
    user.email,
    user.role_memberships.map{|rm| "#{rm.role.name} in #{rm.jurisdiction.name}"}.sort.join("\n")
  ]

end


pdf.table users, :border_style => :grid,
  :row_colors => ["FFFFFF","DDDDDD"],
  :hearders => ["Name", "Email", "Role Assignments"]
