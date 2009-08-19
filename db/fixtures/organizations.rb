Organization.seed(:name) do |o|
  o.name = 'Red Cross'
  o.organization_type = Organization.find_by_name('Non-profit')
  o.approved = true
end