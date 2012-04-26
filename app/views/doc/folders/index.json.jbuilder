
json.folders @folders do |json, folder|
  json.(folder, :id, :parent_id, :level, :name, :ftype, :is_owner, :is_author)
  json.safe_id folder.id.nil? ? 0 : "#{folder.ftype}#{folder.id}"
  if folder.ftype == 'share'
    if folder.id.nil?
      json.safe_id "#{folder.owner.id}#{folder.owner.display_name.gsub(/ /, '')}"
      json.safe_parent_id nil
      json.leaf false
    else
      from_root = folder.parent_id.nil? || @folders.index{|s| s.id == folder.parent_id}.nil?
      if from_root && folder.level != 1
        json.level = 1
        rewrite_level(folder)
      end
      json.safe_parent_id from_root ? "#{folder.owner.id}#{folder.owner.display_name.gsub(/ /, '')}" : "#{folder.ftype}#{folder.parent_id}"
      json.leaf folder.leaf? || @folders.index { |s| s.parent_id == folder.id}.nil?
    end
  elsif folder.ftype == 'organization'
    json.safe_parent_id folder.parent_id.nil? ? nil : "#{folder.ftype}#{folder.parent_id}"
    json.leaf folder.leaf || folder.leaf?
  else
    json.safe_parent_id folder.parent_id.nil? ? (folder.id.nil? ? nil : 0) : "#{folder.ftype}#{folder.parent_id}"
    json.leaf folder.leaf || folder.leaf?
  end
end