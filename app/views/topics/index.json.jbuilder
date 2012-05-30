json.length @topics.length
json.topics @topics do |json, topic|
  json.partial! 'topic', topic: topic
end