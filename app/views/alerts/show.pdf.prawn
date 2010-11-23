pdf.text "Alert Title: #{@alert.title}", :size => 16, :style => :bold, :align => :center
pdf.move_down 10

pdf.define_grid(:columns=>2, :rows=>1, :gutter=>10)
col1 = pdf.grid(0,0)
col2 = pdf.grid(0,1)

# Left Column
pdf.bounding_box col1.top_left, :width=> col1.width, :height => col1.height do
  pdf.move_down 30
  pdf.text @alert.message
  pdf.move_down 10
  pdf.text "Short Message", :style => :bold
  pdf.text @alert.short_message
  pdf.move_down 10
  pdf.text "Author", :style => :bold
  pdf.text @alert.author.display_name
  pdf.move_down 10
  pdf.text "Created at", :style => :bold
  pdf.text @alert.created_at.strftime("%B %d, %Y %I:%M %p %Z")
  pdf.move_down 10
  pdf.text "Disable Cross-Jurisdictional alerting?", :style => :bold
  pdf.text(@alert.not_cross_jurisdictional? ? "Yes" : "No")
  if @alert.has_alert_response_messages?
    @alert.call_down_messages.each do |index, value| 
      pdf.move_down 10
      pdf.text "Alert Response #{index}", :style => :bold
      pdf.text value
    end
  end
end

# Right Column
pdf.bounding_box col2.top_left, :width=> col2.width, :height => col2.height do
  pdf.move_down 30
  pdf.text "Severity", :style => :bold
  pdf.text @alert.severity
  pdf.move_down 10
  pdf.text "Status", :style => :bold
  pdf.text @alert.status
  pdf.move_down 10
  pdf.text "Acknowledge", :style => :bold
  if @alert.acknowledge?
    pdf.text(@alert.has_alert_response_messages? && @alert.original_alert.nil? ? "Advanced" : "Normal")
  else
    pdf.text "None"
  end
  pdf.move_down 10
  pdf.text "Sensitive", :style => :bold
  pdf.text(@alert.sensitive? ? "Yes" : "No")
  pdf.move_down 10
  pdf.text "Delivery Time", :style => :bold
  pdf.text @alert.human_delivery_time
  pdf.move_down 10
  pdf.text "Methods", :style => :bold
  pdf.text @alert.device_types.map{|d| d.constantize.display_name }.to_sentence
  pdf.move_down 10
  pdf.text "Caller ID", :style => :bold
  @alert.caller_id.blank? ? 'None' : @alert.caller_id
end

pdf.text "Alert Audience", :size => 14, :style => :bold, :align => :center
@alert.audiences.each do |audience|
  pdf.move_down 10
  pdf.text "Jurisdictions", :style => :bold
  pdf.text(audience.jurisdictions.blank? ? 'None' : audience.jurisdictions.map(&:name).to_sentence)
  pdf.move_down 10
  pdf.text "Roles", :style => :bold
  pdf.text(audience.roles.blank? ? 'None' : audience.roles.map(&:name).to_sentence)
  pdf.move_down 10
  pdf.text "People", :style => :bold
  pdf.text(audience.users.blank? ? 'No additional people selected' : audience.users.map(&:name).to_sentence)
end

pdf.move_down 10
pdf.text "# of Recipients", :style => :bold
pdf.text @alert.alert_attempts.count.to_s

if @alert.acknowledge?
  pdf.move_down 20
  pdf.text "Contacted Users Acknowledgement Status", :size => 14, :style => :bold, :align => :center
  pdf.move_down 10
  attempts = @alert.alert_attempts.map do |attempt|
    [
      attempt.user.display_name,
      attempt.user.email,
      attempt.acknowledged_alert_device_type.nil? ? "" : attempt.acknowledged_alert_device_type.device.constantize.display_name,
      unless attempt.call_down_response.nil?
        attempt.call_down_response > 0 ? @alert.call_down_messages[attempt.call_down_response.to_s] : "Acknowledged"
      end
    ]
  end

  unless attempts.empty?
    pdf.table attempts, :border_style => :grid,
      :row_colors => ["FFFFFF","DDDDDD"],
      :headers => ["Name", "Email Address", "Acknowledged with Device", "Alert Response"]
  else
    pdf.move_down 10
    pdf.text "No Acknowledgees Found"
  end
end


pdf.move_down 20
pdf.text "Prepared on: #{Time.now.strftime("%Y-%m-%d-%H-%M-%S")} for #{current_user.display_name}",:size => 9
