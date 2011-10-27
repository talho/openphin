class Report::HanAlertLogRecipe < Report::Recipe

  class << self

    def description  # recipe description
      "Report of all han alerts that are within your jurisdictions"
    end

    def helpers
      []
    end

    def template_path
      File.join('reports','alert_log.html.erb')
    end

    def capture_to_db(report)
      dataset = report.dataset
      dataset.insert({"created_at"=>Time.now.utc})
      report.author.han_alerts_within_jurisdictions(nil).each_with_index do |alert,index|
        doc = alert.attributes
        doc["author"] = alert.author.display_name
        doc.delete("author_id")
        doc.delete("id")
        doc.delete("distribution_id")
        doc["i"] = index
        dataset.insert(doc)
      end
    dataset.create_index("i")
    end

  end

end

