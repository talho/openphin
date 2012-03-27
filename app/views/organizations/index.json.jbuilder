json.length @organizations.length
json.organizations @organizations do |json, org|
  json.partial! 'organizations/_organization', org: org
end
