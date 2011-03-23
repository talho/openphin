module AlertsHelper
  
  def jurisdiction_list(form, items = nil)
    items ||= [Jurisdiction.root]
    ul_class = items[0].root? ? 'check_selector' : nil
    jurisdiction_ids = form.object.jurisdiction_ids
    content_tag(:ul, :class => ul_class) do
      items.inject('') do |lis, item|
        lis += content_tag(:li) do
          id = [form.object_name.parameterize('_'), dom_id(item)].join('_')
          html = check_box_tag("#{form.object_name}[jurisdiction_ids][]",
                               item.id,
                               jurisdiction_ids.include?(item.id),
                               :id => id,
                               :class =>"audience_jurisdiction")
          html += label_tag(id, item.name) +"\n"
          unless item.leaf?
            html += link_to_function("Select all children...", "", :class => "hidden select_all" )

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
