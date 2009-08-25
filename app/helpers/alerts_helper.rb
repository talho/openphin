module AlertsHelper
  
  def acknowledge_alert_button(alert)
    if alert.ask_for_acknowledgement?
      button_to 'Acknowledge', acknowledge_alert_path(alert), :method => :put
    end
  end
  
  def jurisdiction_list(form, items = nil)
    items ||= [Jurisdiction.root]
    ul_class = items[0].root? ? 'check_selector' : nil
    content_tag(:ul, :class => ul_class) do
      items.inject('') do |lis, item|
        lis += content_tag(:li) do
          html = check_box_tag('alert[jurisdiction_ids][]', item.id, form.object.jurisdiction_ids.include?(item.id), :id => "alert_jurisdiction_#{item.id}")
          html += label_tag("alert_jurisdiction_#{item.id}", item.name) +"\n"
          if item.children.any?
            html += link_to_function("Select all children...", "select_all_child_jurisdictions()", :class => "hidden select_all" )

            html += jurisdiction_list(form, item.children)+"\n"
          end

          html
        end
        lis
      end
    end
  end
end

# form.object.jurisdiction_ids.include?(item.id)
