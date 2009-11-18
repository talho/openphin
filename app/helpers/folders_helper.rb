module FoldersHelper
  def folders_links(folders)
    output = ""
    folders.each do |f|
      output += "<li class=\"folder\">"
      output += link_to f.name,documents_panel_path(f.id)
      output += folders_links(f.children) if f.children
      output += "</li>"
    end
    output
  end
end
