federal = Jurisdiction.seed(:name) do |j|
  j.name = 'Federal'
end

texas = Jurisdiction.seed(:name) do |j|
  j.name = 'Texas'
  j.fips_code = '01091'
end
texas.move_to_child_of(federal)

FasterCSV.open(File.join(RAILS_ROOT, "db/fixtures/regions.csv"), :headers => true) do |roles|
  roles.each do |row|
    Region.seed(:name) do |region|
      region.id = row['id']
      region.name = row['name']
    end
  end
end

FasterCSV.open(File.join(RAILS_ROOT, "db/fixtures/jurisdictions.csv"), :headers => true) do |roles|
  roles.each do |row|
    Jurisdiction.seed(:name) do |region|
      region.name = row['name'].strip
      region.region_id = row['region_id']
      region.fips_code = row['fips_code']
    end.move_to_child_of(texas)
  end
end
