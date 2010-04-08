pdf.text "Invitation Report for #{invitation.name} by organization", :size => 12, :style => :bold
pdf.move_down 10
pdf.text "#{invitation.default_organization.name}"

invitees = results.map do |invitee|
  [
    invitee.name,
    invitee.email,
    invitee.is_member?
  ]
end

unless invitees.empty?
  pdf.table invitees, :border_style => :grid,
    :row_colors => ["FFFFFF","DDDDDD"],
    :headers => ["Name", "Email Address", "Is Member?"]
else
  pdf.move_down 10
  pdf.text "No Invitees Found"
end

pdf.move_down 20
pdf.text "Prepared on: #{@timestamp}"
