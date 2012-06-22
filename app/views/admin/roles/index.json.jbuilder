
json.array! @roles do |json, role|
  json.partial! 'role', role: role
end