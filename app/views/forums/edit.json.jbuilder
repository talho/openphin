json.success true
json.data do |json|  
  json.partial! 'forum', forum: @forum
end