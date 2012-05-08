json.comments @topics do |json, topic|
  json.partial! 'topic', topic: topic
end