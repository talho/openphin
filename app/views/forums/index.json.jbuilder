json.forums @forums do |json, forum|
  json.partial! 'forum', forum: forum
end