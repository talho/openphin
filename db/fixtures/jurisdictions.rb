federal = Jurisdiction.find_or_create_by_name(:name => "Federal") { |j|
  #j.fips_code = 'US'
  j.foreign = true
}

texas = Jurisdiction.find_or_create_by_name(:name => "Texas") { |j|
  j.fips_code = '01091'
  j.foreign = false
}
texas.move_to_child_of(federal) unless federal.children.include?(texas)

CSV.open(File.join(RAILS_ROOT, "db/fixtures/jurisdiction_regions.csv"), :headers => true) do |roles|
  roles.each do |row|
    j = Jurisdiction.find_or_create_by_name(:name => row['name'].strip)
    j.move_to_child_of(texas) unless texas.children.include?(j)
  end
end

CSV.open(File.join(RAILS_ROOT, "db/fixtures/jurisdictions.csv"), :headers => true) do |roles|
  roles.each do |row|
    m = Jurisdiction.find_or_create_by_name_and_fips_code(:name => row['name'].strip, :fips_code => row['fips_code'])
    region = Jurisdiction.find_by_name!(row['region_name'])
    m.move_to_child_of region unless region.children.include?(m)
  end
end

louisiana=Jurisdiction.find_or_create_by_name(:name => "Louisiana") { |j|
  j.foreign=true
  j.fips_code = "22"
}
louisiana.move_to_child_of(Jurisdiction.root) unless Jurisdiction.root.children.include?(louisiana)

{"Caldwell" => "22021", "Beauregard" => "22011", "Calcasieu" => "22019"}.each do |parish, fips|
  p=Jurisdiction.find_or_create_by_name_and_fips_code(:name => parish, :fips_code => fips) { |j|
    j.foreign=true
  }
  p.move_to_child_of louisiana unless louisiana.children.include?(p)
end

indiana=Jurisdiction.find_or_create_by_name(:name => "Indiana") { |j|
  j.foreign=true
  j.fips_code = "18"
}
indiana.move_to_child_of(Jurisdiction.root) unless Jurisdiction.root.children.include?(indiana)

salud=Jurisdiction.find_or_create_by_name(:name => "Puerto Rico") { |j|
  j.foreign=true
  j.fips_code = "72"
}
salud.move_to_child_of(Jurisdiction.root) unless Jurisdiction.root.children.include?(salud)
