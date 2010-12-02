pdf.text "Invitation Report for #{invitation.name} by pending role requests", :size => 12, :style => :bold

invitees = results.map do |invitee|
  [
    invitee.name,
    invitee.email,
    invitee.user ? invitee.user.role_requests.collect{|rr| rr.role.name}.join("\n") : ''
  ]
end

unless invitees.empty?
  pdf.table invitees, :border_style => :grid,
    :row_colors => ["FFFFFF","DDDDDD"],
    :headers => ["Name", "Email Address", "Pending Role Requests"]
else
  pdf.move_down 10
  pdf.text "No Invitees Found"
end

pdf.move_down 20
pdf.text "Prepared on: #{@timestamp} for: #{current_user.display_name}", :size => 9
