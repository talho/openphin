
json.array! @requests do |json, req|
  json.(req, :id)
  json.name req.user.display_name
  json.organization req.organization.name
  json.email req.user.email
end
