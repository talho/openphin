schools=File.open(File.dirname(__FILE__) + '/schools.csv').read.split("\n").map{|row| row.split("|")}
SchoolDistrict.seed(:name) do |district|
  district.name="Houston ISD"
  district.jurisdiction=Jurisdiction.find_or_create_by_name("Harris")
end
@district=SchoolDistrict.find_by_name("Houston ISD")
schools.each do |school|
  if school[0].nil?
    puts "Could not create a school for #{school[0]}; incomplete information"
    next
  end
  puts "seeding #{school[0]}"
  School.seed(:display_name) do |s|
    s.district=@district
    s.display_name = school[0]
#    s.name=school[0]
#    s.region=school[1]
#    s.school_number = school[3]
#    s.display_name=school[0].strip.gsub(/(Elementary School$|Montessori$|Elementary$)/, "ES").
#          gsub(/High School$/, "HS").
#          gsub(/Middle School$/, "MS").
#          gsub(/Early Childhood Education Center$/,"ECC").upcase
  end
end