
json.success true
json.data do |json|  
  json.partial! 'admin/organizations/_organization', org: @organization
end
