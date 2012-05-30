json.(topic, :forum_id, :comment_id, :name, :content, :created_at, :updated_at, :lock_version, :id, :locked_at, :poster_id, :hidden_at, :sticky)
json.posts topic.comments.length
json.is_super_admin current_user.is_super_admin?
json.is_forum_admin current_user.is_admin?("phin")
json.is_moderator current_user.moderator_of?(Forum.find(topic.forum_id))
json.is_user_owned current_user.id == topic.poster_id ? true : false
json.locked topic.locked_at ? 1 : 0
json.poster_name topic.poster.display_name
json.user_avatar User.find(topic.poster_id).photo.url(:tiny)
json.formatted_content RedCloth.new(topic.content).to_html