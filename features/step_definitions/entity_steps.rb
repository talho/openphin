Given 'the following entities exists:' do |table|
  table.rows.each do |row|
     Given "a #{row[0].downcase} named #{row[1]}"
  end
end
