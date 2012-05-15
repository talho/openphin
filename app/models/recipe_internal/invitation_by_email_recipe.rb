class RecipeInternal::InvitationByEmailRecipe < RecipeInternal

  class << self

    def description
      "Report of all invitees of a invitation by email."
    end

    def helpers
      []
    end

    def template_path
      File.join('reports','admin','invitations','show_by_email.html.erb')
    end

    def template_directives
      [['name','Name'],['email','Email Address'],['completionStatus','Completion Status'],['organizationMembership','Organization Membership'],
       ['profileUpdated','Profile Updated'],['pendingRequests','Pending Role Requests']]
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
     entries = report.dataset.find( id.merge( :i=>{:$exists=>true} )).to_a
     meta = report.dataset.find( id.merge( {:meta=>{:$exists=>true}} )).first["meta"]
     Dir.mktmpdir do |dir|
       path = File.join dir, filename
       File.open(path, 'wb') do |f|
         rendering = view.render(
           :file=>template,
           :locals=>{
              :report=>invitation,
              :entries=>entries,
              :directives=>meta["template_directives"],
              :stats=>meta["stats"],
              :filters=>filters
              },
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
          data_set.insert( id.merge( {:report=>result.as_report(:inject=>{:created_at=>Time.now.utc})}))
          stats = {
            :registrations=>{
              :complete=>{:percentage=>result.registrations_complete_percentage,:total=>result.registrations_complete_total},
              :incomplete=>{:percentage=>result.registrations_incomplete_percentage,:total=>result.registrations_incomplete_total}}}
          data_set.insert( id.merge( {:meta=>{:stats=>stats,:template_directives=>template_directives}}.as_json ))
          index = 0
          result.invitees.sort{|x,y| x.name <=> y.name}.each do |invitee|
            begin
              doc = id.clone
              doc[:name] = invitee.name
              doc[:email] = invitee.email
              doc[:completionStatus] = invitee.completion_status
              doc[:organizationMembership] = result.default_organization ? invitee.is_member? : 'N/A'
              doc[:profileUpdated] = invitee.user && invitee.user.updated_at > result.created_at ? "Yes" : "No"
              doc[:pendingRequests] = pending_requests(invitee)
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

    def pending_requests(invitee)
      requests = []
      if invitee.user
        requests = invitee.user.role_requests.unapproved.map do |rr|
          if current_user.is_admin_for?(rr.jurisdiction)
            {
                :role => rr.role.name,
                :jurisdiction => rr.jurisdiction.name
            }
          else
            nil
          end
        end
      end
      requests = requests.compact
      requests.blank? ? "" : requests
    end

  end

end


