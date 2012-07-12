
json.array! @apps do |json, app|
  json.partial! 'app', app: app
end
