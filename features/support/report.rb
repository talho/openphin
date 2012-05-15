After('@clear_report_db') do
  REPORT_DB.collection_names.grep(/-Recipe-/){|c| REPORT_DB.drop_collection(c)}
end

