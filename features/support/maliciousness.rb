module FeatureHelpers
  module Maliciousness
    
    def maliciously_post_assign_role_form(table)
      params = {}
      table.rows_hash.each do |label, value|
        case label
        when "People"
          value.split(',').each do |name|
            user = Given "a user named #{name.strip}"
            params[:user_ids] ||= []
            params[:user_ids] << user.id
          end
        when "Role"
          params[:role_id] = Role.find_by_name!(value).id
        when "Jurisdiction"
          params[:jurisdiction_id] = Jurisdiction.find_by_name!(value).id
        else
          raise "Unknown field '#{label}'.  You may need to update this step."
        end
      end
      post(role_assignments_path, :role_assigns => params)
    end
    
  end
end

World(FeatureHelpers::Maliciousness)