
json.reports @reports do |report|
  json.(report, :id)
  json.date report.created_at
  json.name report.class.to_s
end
