pdf.text "Invitation Report for #{invitation.name} by Profile Update", :size => 12, :style => :bold
pdf.move_down 10
pdf.text "Registrations complete: #{invitation.registrations_complete_percentage}% (#{invitation.registrations_complete_total})"
pdf.move_down 10
pdf.text "Registrations incomplete: #{invitation.registrations_incomplete_percentage}% (#{invitation.registrations_incomplete_total})"
pdf.move_down 10

invitees = results.map do |invitee|
  [
    invitee.name,
    invitee.email,
    invitee.user.updated_at
  ]
end

unless invitees.empty?
  pdf.table invitees, :border_style => :grid,
    :row_colors => ["FFFFFF","DDDDDD"],
    :headers => ["Name", "Email Address", "Profile Updated At"]
else
  pdf.move_down 10
  pdf.text "No Invitees Found"
end

pdf.move_down 20
pdf.text "Prepared on: #{@timestamp} for: #{current_user.display_name}", :size => 9
