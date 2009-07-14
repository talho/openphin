Given 'the following entities exists:' do |table|
  table.rows_hash.each do |key, value|
     Given "a #{key.downcase} named #{value}"
  end
end
