
json.reports @report_types do |report|
  json.name report.name
  json.type report.to_s
end
