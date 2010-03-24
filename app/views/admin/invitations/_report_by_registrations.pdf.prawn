pdf.text "Invitation Report for #{invitation.name} by registration", :size => 12, :style => :bold
pdf.move_down 10
pdf.text "Registrations complete: #{invitation.registrations_complete_percentage}% (#{invitation.registrations_complete_total})"
pdf.move_down 10
pdf.text "Registrations incomplete: #{invitation.registrations_incomplete_percentage}% (#{invitation.registrations_incomplete_total})"
pdf.move_down 10

invitees = results.map do |invitee|
  [
    invitee.name,
    invitee.email,
    invitee.completion_status
  ]
  
end

unless invitees.empty?
  pdf.table invitees, :border_style => :grid,
    :row_colors => ["FFFFFF","DDDDDD"],
    :headers => ["Name", "Email Address", "Completion Status"]
else
  pdf.move_down 10
  pdf.text "No Invitees Found"
end
