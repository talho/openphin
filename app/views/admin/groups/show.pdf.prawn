pdf.font_size 10.0
pdf.text "Group Recipient Export", :size => 30, :style => :bold
pdf.text "For Group: #{@group.name}", :size => 25, :style => :bold

width = 173.333333333333
height = 15.0
height_position = 600.0

c1 = pdf.bounding_box [0.0, height_position], :width => width, :height => height do
  pdf.text "Name"
  pdf.stroke do
    pdf.rectangle([0.0, height_position], width, height)
  end
end

c2 = pdf.bounding_box [183.333333333333, height_position], :width => width, :height => height do
  pdf.text "Email"
  pdf.stroke do
    pdf.rectangle([183.333333333333, height_position], width, height)
  end
end

c3 = pdf.bounding_box [366.666666666667, height_position], :width => width, :height => height do
  pdf.text "Role Assignments"
  pdf.stroke do
    pdf.rectangle([366.666666666667, height_position], width, height)
  end
end

height_position -= height

@group.recipients(:order => "last_name").find_in_batches(:batch_size => 1000) { |users|
  users.each do |user|
    name = user.display_name
    height = pdf.height_of(name)
    email = user.email

    height = pdf.height_of(email) if height < pdf.height_of(email)
    memberships = user.role_memberships.map{|rm| "#{rm.role.name} in #{rm.jurisdiction.name}"}.join('\n')
    height = pdf.height_of(memberships) if height < pdf.height_of(memberships)

    if height_position - height < 0
      pdf.start_new_page
      height_position = 700.0
    end

    c1 = pdf.bounding_box [0.0, height_position], :width => width do
      pdf.text name
      #pdf.stroke do
      #  pdf.rectangle([0.0, height_position], width, height)
      #end
    end

    height = c1.height if height < c1.height

    c2 = pdf.bounding_box [183.333333333333, height_position], :width => width do
      pdf.text email
      #pdf.stroke do
      #  pdf.rectangle([183.333333333333, height_position], width, height)
      #end
    end

    height = c2.height if height < c2.height

    c3 = pdf.bounding_box [366.666666666667, height_position], :width => width do
      pdf.text memberships
      #pdf.stroke do
      #  pdf.rectangle([366.666666666667, height_position], width, height)
      #end
    end

    height = c3.height if height < c3.height

    height_position -= height
  end
}
