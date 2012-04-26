
json.files @folders + @documents do |json, fd|
  json.(fd, :id, :name, :created_at, :updated_at)
  if fd.is_a? Folder
    folder = fd
    json.ftype 'folder'
    json.is_owner folder.owner?(current_user)
    json.is_author folder.author?(current_user)
  elsif fd.is_a? Document
    document = fd
    json.(document, :ftype, :file_file_size)
    json.is_author document.editable_by?(current_user)
    json.is_owner document.owner_id == current_user.id
    json.doc_path document_path(document)
  end
end