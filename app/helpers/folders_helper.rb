module FoldersHelper
  def folders_links(folders, parent_form = nil)
    output = ""
    folders.each do |f|
      output += "<ul>"
      output += "<li class=\"folder\">"
      if parent_form
        output += parent_form.label :name, f.name, :style => "display: none;"
        output += parent_form.check_box(:name, {}, f.id)
      end
      output += link_to f.name,folder_documents_path(f.id)
      output += folders_links(f.children, parent_form) if f.children
      output += "</li>"
      output += "</ul>"
    end
    output
  end
end
