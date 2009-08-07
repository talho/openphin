federal = Jurisdiction.seed(:name) do |j|
  j.name = 'Federal'
end

texas = Jurisdiction.seed(:name) do |j|
  j.name = 'Texas'
  j.fips_code = '01091'
end
texas.move_to_child_of(federal)

FasterCSV.open(File.join(RAILS_ROOT, "db/fixtures/jurisdiction_regions.csv"), :headers => true) do |roles|
  roles.each do |row|
    Jurisdiction.seed(:name) do |region|
      region.name = row['name']
    end.move_to_child_of(texas)
  end
end

FasterCSV.open(File.join(RAILS_ROOT, "db/fixtures/jurisdictions.csv"), :headers => true) do |roles|
  roles.each do |row|
    m = Jurisdiction.seed(:name) do |region|
      region.name = row['name'].strip
      region.fips_code = row['fips_code']
    end
    m.move_to_child_of Jurisdiction.find_by_name!(row['region_name'])
  end
end
