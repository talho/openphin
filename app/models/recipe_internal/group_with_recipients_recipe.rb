class RecipeInternal::GroupWithRecipientsRecipe < RecipeInternal

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

    def template_directives
      [['display_name','Name'],['email','Email Address'],['role_memberships','Roles','to_rpt']]
    end

    def current_user
      @current_user
    end

    def capture_to_db(report)
      @current_user = report.author
      data_set = report.dataset
      id = {:report_id => report.id}
      if report.criteria.present?
        criteria = report.criteria
        begin
          result = criteria[:model].constantize.send(criteria[:method],criteria[:params])
          data_set.insert( id.merge( {:report=>result.as_report(:inject=>{:created_at=>Time.now.utc})} ))
          data_set.insert( id.merge( {:meta=>{:template_directives=>template_directives}}.as_json ))
          index = 0
          result.recipients.sort{|x,y| x.name <=> y.name}.each do |u|
            begin
              doc = id.clone
              doc[:display_name] = u.display_name
              doc[:email] = u.email
              doc[:role_memberships] = u.role_memberships.map(&:as_hash)
              doc[:i] = index += 1
              data_set.insert(doc)
            rescue NoMethodError
              #skip illegitimate entry
            end
          end
          data_set.create_index(:i)
        rescue StandardError => error
          raise error
        end
      end
    end

    def generate_rendering( report, view, template, filters=nil )
      id = {:report_id => report.id}
      where = id.clone
      filename = "#{report.name}.html"
      if filters.present?
        filtered_at = filters["filtered_at"]
        filename = "#{report.name}#{filtered_at.nil? ? "" : "-#{filtered_at}"}.html"
        where = where.merge(filters_for_query(filters["elements"]))
      end
      subject = report.dataset.find( id.merge( {:report=>{:$exists=>true}} )).first['report']
      meta = report.dataset.find( id.merge( {:meta=>{:$exists=>true}} )).first["meta"]
      result = report.dataset.find(id.merge( :i=>{:$exists=>true} )).to_a
      Dir.mktmpdir do |dir|
        path = File.join dir, filename
        File.open(path, 'wb') do |f|
          rendering = view.render(
            :file=>template,
            :locals=>{
                :report=>subject,
                :entries=>result,
                :directives=>meta["template_directives"],
                :filters=>filters
            },
            :layout=>layout_path)
            f.write(rendering)
        end
        report.update_attributes( :rendering=>File.new(path, "rb"), :incomplete=>false )
      end
    end

  end

end
  
  
