json.length @organizations.length
json.organizations @organizations do |json, org|
  json.partial! 'organization', org: org
end
