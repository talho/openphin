module AlertsHelper
  
  def acknowledge_alert_button(alert)
    if alert.ask_for_acknowledgement?
      button_to 'Acknowledge', acknowledge_alert_path(alert), :method => :put
    end
  end
  
  def jurisdiction_list(items = nil)
    items ||= [Jurisdiction.root]
    ul_class = items[0].root? ? 'check_selector' : nil
    content_tag(:ul, :class => ul_class) do
      items.inject('') do |lis, item|
        lis += content_tag(:li) do
          html = check_box_tag 'alert[jurisdiction_ids][]', item.id, nil, :id => "alert_jurisdiction_#{item.id}"
          html += label_tag "alert_jurisdiction_#{item.id}", item.name
          html += jurisdiction_list(item.children) if item.children.any?
          html
        end
        lis
      end
    end
  end
end

# form.object.jurisdiction_ids.include?(item.id)