json.success true
json.data do |json|
  json.partial! 'topic', topic: @topic
end