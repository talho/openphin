class RecipeInternal::InvitationByOrganizationRecipe < RecipeInternal

  class << self

    def description
      "Report of all invitees of a invitation by organization."
    end

    def helpers
      []
    end

    def template_path
      File.join('reports','admin','invitations','show_by_organization.html.erb')
    end

    def template_directives
      [['name','Name'],['email','Email Address'],['is_member','Is Member?']]
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
     invitation = report.dataset.find( id.merge( {:report=>{:$exists=>true}} )).first['report']
     @entries = report.dataset.find( id.merge( :i=>{:$exists=>true} ))
     Dir.mktmpdir do |dir|
       path = File.join dir, filename
       File.open(path, 'wb') do |f|
         rendering = view.render(
           :inline=>template,:type=>'html',
           :locals=>{:report=>invitation,:entries=>@entries,:directives=>template_directives,:filters=>filters},
           :layout=>layout_path)
         f.write(rendering)
       end
       report.update_attributes( :rendering=>File.new(path, "rb"), :incomplete=>false )
     end
    end

    def current_user
      @current_user
    end

    def capture_to_db(report)
      id = {:report_id => report.id}
      @current_user = report.author
      data_set = report.dataset
      if report.criteria.present?
        criteria = report.criteria
        begin
          # Invitation.find(params)
          result = criteria[:model].constantize.send(criteria[:method],criteria[:params])
          data_set.insert( id.merge( {:report=>result.as_report(:inject=>{:created_at=>Time.now.utc})} ))
          data_set.insert( id.merge( {:meta=>{:template_directives=>template_directives}} ) )

          select = "DISTINCT invitees.*, audiences.id AS audience_id"
          joins = "LEFT JOIN users ON invitees.email = users.email " +
                    "LEFT JOIN audiences_users ON users.id = audiences_users.user_id " +
                    "LEFT JOIN audiences ON audiences_users.audience_id = audiences.id AND audiences.scope='Organization'"
          order = "audience_id ASC"

          index = 0
          result.invitees.each do |u|
            begin
              doc = id.clone
              doc[:name] = u.name
              doc[:email] = u.email
              doc[:is_member] = u.is_member?
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

  end

end

