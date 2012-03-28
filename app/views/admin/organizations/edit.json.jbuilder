
json.success true
json.data do |json|  
  json.partial! 'organization', org: @organization
end
