json.audience do |json|
  json.id audience.id
  json.users audience.users do |json, u|
    json.(u, :id, :email)
    json.name u.display_name
    json.profile_path user_profile_path(u)
  end
  json.jurisdictions audience.jurisdictions, :id, :name
  json.roles audience.roles, :id, :name
end