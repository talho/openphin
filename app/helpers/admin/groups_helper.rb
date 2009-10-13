module Admin::GroupsHelper
  def group_jurisdiction_list(form, items = nil)
    items ||= [Jurisdiction.root]
    ul_class = items[0].root? ? 'check_selector jurisdictions' : nil
    content_tag(:ul, :class => ul_class) do
      items.inject('') do |lis, item|
        lis += content_tag(:li) do
          html = check_box_tag('group[jurisdiction_ids][]', item.id, form.object.jurisdiction_ids.include?(item.id), :id => "group_jurisdiction_#{item.id}")
          html += label_tag("group_jurisdiction_#{item.id}", item.name, :class => "jurisdiction") +"\n"
          if item.children.any?
            html += link_to_function("Select all children...", "select_all_child_jurisdictions()", :class => "hidden select_all" )

            html += group_jurisdiction_list(form, item.children)+"\n"
          end

          html
        end
        lis
      end
    end
  end
end
