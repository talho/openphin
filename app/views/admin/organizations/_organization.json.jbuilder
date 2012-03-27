json.partial! 'organizations/_organization', org: org
json.contact do |json|
  json.(org.contact, :id, :email)
  json.name org.contact.display_name
end if org.contact

json.audience do |json|
  json.users org.audience.users do |json, u|
    json.(u, :id, :email)
    json.name u.display_name
    json.profile_path user_profile_path(u)
  end
  json.jurisdictions org.audience.jurisdictions, :id, :name
  json.roles org.audience.roles, :id, :name
end