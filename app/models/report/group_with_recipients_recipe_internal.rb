class Report::GroupWithRecipientsRecipeInternal < Report::Recipe

  class << self

    def description
      "Report of all recipients of the group including their name, email, role assignments, email devices, phone devices, sms devices and blackberry devices."
    end

    def helpers
      ['RoleMembershipsHelper']
    end

    def template_path
      File.join('reports','admin','groups','show.html.erb')
    end

    def capture_to_db(report)
      data_set = report.dataset
      if report.criteria.present?
        criteria = report.criteria
        begin
          result = criteria[:model].constantize.send(criteria[:method],criteria[:params])
          data = {}
          data[:created_at] = Time.now.utc
          data[:name] = result.name
          data[:jurisdictions] = result.jurisdictions.map(&:name)
          data[:roles] = result.roles.map(&:name)
          data[:scope] = result.scope
          data[:owner_jurisdiction] = result.owner_jurisdiction.name
          data_set.insert data
          result.recipients.each_with_index do |r,i|
            doc = {:i=>(i+1),:display_name=>r.display_name,:email=>r.email,:role_memberships=>r.role_memberships.map(&:as_hash)}
            data_set.insert(doc)
          end
          data_set.create_index(:i)
        rescue StandardError => error
          raise error
        end
      end
    end

    def generate_rendering_of_on_with( report, view, template, filters=nil )
     where = {}
     filename = "#{report.name}.html"
     if filters.present?
       filtered_at = filters["filtered_at"]
       filename = "#{report.name}#{filtered_at.nil? ? "" : "-#{filtered_at}"}.html"
       where = where.merge(filters_for_query(filters["elements"]))
     end
     results = []
     header = report.dataset.find_one()
     result = report.dataset.find(:i=>{:$exists=>true})
     Dir.mktmpdir do |dir|
       path = File.join dir, filename
       File.open(path, 'wb') do |f|
         rendering = view.render(:inline=>template,:type=>'html',
                                 :locals=>{:header=>header,:result=>result,:filters=>filters}, :layout=>"reports/layouts/report")
         f.write(rendering)
       end
       report.update_attributes( :rendering=>File.new(path, "rb"), :incomplete=>false )
     end
    end

  end

end
  
  
