federal = Jurisdiction.seed(:name) do |j|
  j.name = 'Federal'
end

texas = Jurisdiction.seed(:name) do |j|
  j.name = 'Texas'
end
texas.move_to_child_of(federal)

Jurisdiction.seed(:name) do |j|
  j.name = 'Dallas County'
end.move_to_child_of(texas)

Jurisdiction.seed(:name) do |j|
  j.name = 'Tarrant County'
end.move_to_child_of(texas)

Jurisdiction.seed(:name) do |j|
  j.name = 'Potter County'
end.move_to_child_of(texas)

Jurisdiction.seed(:name) do |j|
  j.name = 'Wise County'
end.move_to_child_of(texas)