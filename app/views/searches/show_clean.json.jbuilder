
json.total @total
json.users @results do |json, u|
  json.partial! 'user', u: u
end