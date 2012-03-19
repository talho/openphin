class RecipeInternal::InvitationByPendingRoleRequestsRecipe < RecipeInternal

  class << self

    def description
      "Report of all invitees of a invitation by pending role requests."
    end

    def helpers
      ['RoleRequestsHelper']
    end

    def template_path
      File.join('reports','admin','invitations','show_by_pending_role_requests.html.erb')
    end

    def template_directives
      [['name','Name'],['email','Email Address'],['role_requests','Pending Role Requests','to_rpt']]
    end

    def generate_rendering( report, view, template, filters=nil )
     where = {}
     filename = "#{report.name}.html"
     if filters.present?
       filtered_at = filters["filtered_at"]
       filename = "#{report.name}#{filtered_at.nil? ? "" : "-#{filtered_at}"}.html"
       where = where.merge(filters_for_query(filters["elements"]))
     end
     invitation = report.dataset.find({:report=>{:$exists=>true}}).first['report']
     entries = report.dataset.find(:i=>{:$exists=>true})
     Dir.mktmpdir do |dir|
       path = File.join dir, filename
       File.open(path, 'wb') do |f|
         rendering = view.render(
           :inline=>template,:type=>'html',
           :locals=>{:report=>invitation,:entries=>entries,:directives=>template_directives,:filters=>filters},
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
      @current_user = report.author
      data_set = report.dataset
      if report.criteria.present?
        criteria = report.criteria
        begin
          # Invitation.find(params)
          result = criteria[:model].constantize.send(criteria[:method],criteria[:params])
          data_set.insert({:report=>result.as_report(:inject=>{:created_at=>Time.now.utc})})
          data_set.insert( {:meta=>{:template_directives=>template_directives}}.as_json )

          jurisdiction_ids = report.author.role_memberships.admin_roles.map(&:jurisdiction_id).join(',')
          select = "DISTINCT invitees.*, role_requests.id IS NULL AS role_requests_id"
          joins = "LEFT JOIN users ON invitees.email = users.email " +
                  "LEFT JOIN role_requests ON users.id = role_requests.user_id " +
                  "AND role_requests.jurisdiction_id IN (#{jurisdiction_ids})"
          order = "role_requests_id ASC"

          result.invitees.find(:all,:select=>select,:joins=>joins,:order=>order).each_with_index do |invitee,i|
            data = {:i=>(i+1),
                    :name=>invitee.name,
                    :email=>invitee.email,
                    :role_requests=>invitee.user.role_requests.map(&:as_hash)}
            data_set.insert(data)
          end
          data_set.create_index(:i)
        rescue StandardError => error
          raise error
        end
      end
    end

  end

end

