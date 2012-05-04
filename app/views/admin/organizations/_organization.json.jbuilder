json.partial! 'organizations/organization', org: org

if org.contact
  json.contact do |json|
    json.(org.contact, :id, :email)
    json.name org.contact.display_name
  end
else
  json.contact nil
end

json.audience do |json|
  json.users org.group.users do |json, u|
    json.(u, :id, :email)
    json.name u.display_name
    json.profile_path user_profile_path(u)
  end
  json.jurisdictions org.group.jurisdictions, :id, :name
  json.roles org.group.roles, :id, :name
end