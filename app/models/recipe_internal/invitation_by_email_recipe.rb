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
      [['name','Name'],['email','Email Address'],['completion_status','Completion Status']]
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
     meta = report.dataset.find({:meta=>{:$exists=>true}}).first["meta"]
     Dir.mktmpdir do |dir|
       path = File.join dir, filename
       File.open(path, 'wb') do |f|
         rendering = view.render(
           :inline=>template,:type=>'html',
           :locals=>{
              :report=>invitation,
              :entries=>entries,
              :directives=>meta["template_directives"],
              :stats=>meta["stats"],
              :filters=>filters},
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
          stats = {
            :registrations=>{
              :complete=>{:percentage=>result.registrations_complete_percentage,:total=>result.registrations_complete_total},
              :incomplete=>{:percentage=>result.registrations_incomplete_percentage,:total=>result.registrations_incomplete_total}}}
          data_set.insert( {:meta=>{:stats=>stats,:template_directives=>template_directives}}.as_json )
          result.invitees.each_with_index do |r,i|
            doc = {:i=>(i+1),:name=>r.name,:email=>r.email,:completion_status=>r.completion_status}
            data_set.insert(doc)
          end
          data_set.create_index(:i)
        rescue StandardError => error
          raise error
        end
      end
    end

  end

end


