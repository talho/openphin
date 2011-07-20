REPORT_DB = Mongo::Connection.new("localhost",27017,:pool_size=>5,:timeout=>5).db("openphin_#{Rails.env}")

# removing a recipe class whose code has been removed from the system
# a find(:all) on this STI will throw a SubclassNotFound otherwise
recipe_count = Report::Recipe.count
id = count = 0
while count < recipe_count do
  begin
    id += 1
    Report::Recipe.find(id)
    count += 1
  rescue ActiveRecord::SubclassNotFound
    Report::Recipe.delete(id)
  end
end
