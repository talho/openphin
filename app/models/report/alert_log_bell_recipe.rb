class Report::AlertLogBellRecipe < Report::Recipe

  def description  # recipe description
    "Report of all logged alerts for Bell County"
  end

  def helpers
  end

  def template_path
    File.join(Rails.root,'app','views','reports','alert_log.html.erb')
  end

  def after_create
    roles = [Role.find_by_name("Health Alert and Communications Coordinator")]
    aud = Audience.new( :roles=>roles,:jurisdictions=>[Jurisdiction.find_by_name("Bell")] )
    aud.recipients(:force => true).length if aud # apply the recipients for the audience so that the mapped joins will actually work
     update_attribute(:audience,aud)
  end

  def capture_to_db(report)
    dataset = report.dataset
    dataset.insert({"created_at"=>Time.now.utc})
    i = 1
    report.author.recent_han_alerts.each do |alert|
      doc = alert.attributes
      doc["author"] = alert.author.display_name
      doc.delete("author_id")
      doc.delete("id")
      doc.delete("distribution_id")
      doc["i"] = i
      dataset.insert(doc)
      i += 1
    end
  dataset.create_index("i")
  end

end

