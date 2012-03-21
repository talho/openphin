class RecipeInternal::HanAlertLogRecipe < Recipe

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

    def template_directives
      [ ['identifier','Identifier'],['title','Title'],['author','Author'],
        ['created_at','Created At'],['severity','Severity'],['status','Status'],
        ['acknowledge','Acknowledge'],['sensitive','Sensitive'],['delivery_time','Delivery Time'],
        ['not_cross_jurisdictional','Cross-Jurisdictional'],['short_message','Short Message'],['message','Message']
      ]
    end

    def current_user
      @current_user
    end

    def capture_to_db(report)
      @current_user = report.author
      dataset = report.dataset
      dataset.insert({:report=>{"created_at"=>Time.now.utc}})
      dataset.insert( {:meta=>{:template_directives=>template_directives}}.as_json )
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

