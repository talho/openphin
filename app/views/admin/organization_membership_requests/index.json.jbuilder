
json.array! @requests do |json, req|
  json.(req, :id)
  json.name r.user.display_name
  json.organization r.organization.name
  json.email r.user.email
end
