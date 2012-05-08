json.(forum, :name, :hide, :created_at, :updated_at, :id)
json.threads forum.topics.length
json.is_super_admin current_user.is_super_admin?
json.is_forum_admin current_user.is_admin?
json.is_moderator current_user.moderator_of?(forum)
json.is_owner current_user.forum_owner_of?(forum)
if forum.audience
  json.partial! 'audiences/audience', audience: forum.audience
end