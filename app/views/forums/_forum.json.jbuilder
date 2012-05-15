json.(forum, :name, :hide, :created_at, :updated_at, :id)
json.threads forum.topics.length
json.is_super_admin current_user.is_super_admin?
json.is_forum_admin current_user.is_admin?
json.is_moderator current_user.moderator_of?(forum)
json.is_owner current_user.forum_owner_of?(forum)
if forum.audience
  json.audience do |json|
    p forum.audience.id
    json.id forum.audience.id
    json.users forum.audience.users do |json, u|
      json.(u, :id, :email)
      json.name u.display_name
      json.profile_path user_profile_path(u)
    end
    json.jurisdictions forum.audience.jurisdictions, :id, :name
    json.roles forum.audience.roles, :id, :name
  end
end
if forum.moderator_audience
  json.moderator_audience do |json|
    p forum.moderator_audience.id
    json.id forum.moderator_audience.id
    json.users forum.moderator_audience.users do |json, u|
      json.(u, :id, :email)
      json.name u.display_name
      json.profile_path user_profile_path(u)
    end
    json.jurisdictions forum.moderator_audience.jurisdictions, :id, :name
    json.roles forum.moderator_audience.roles, :id, :name
  end
end