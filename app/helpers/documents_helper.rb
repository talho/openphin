module DocumentsHelper
  def tooltip(document)
    output = "File Size: #{number_to_human_size document.file_file_size}<br/>"
    output += "Created at: #{document.file_updated_at.strftime("%B %d, %Y %I:%M %p %Z")}<br/>"
    output += "Owner: #{document.owner.display_name}" unless document.owner.nil?
    h output
  end
end