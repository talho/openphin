
json.array! @apps do |json, app|
  json.(app, :id, :name, :domains)
end
