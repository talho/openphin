federal = Jurisdiction.find_or_create_by_name(:name => "Federal") do |j|
  j.fips_code = 'US'
end
