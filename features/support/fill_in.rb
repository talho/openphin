module FeatureHelpers
  module FillInMethods
    def fill_in_signup_form(table = nil)
      fields={"Email"=> "john@example.com",
          "Password"=> "password",
          "Password confirmation"=> "password",
          "First name"=> "John",
          "Last name"=> "Smith",
          "Preferred name"=> "Jonathan Smith",
          "Are you with any of these organizations"=> "Red Cross",
          "What County"=> "Dallas County",
          "What is your primary role within the health department"=> "Health Alert and Communications Coordinator",
          "Preferred language"=> "English"
      }
      if table.is_a?(Hash)
        fields.merge!(table)
      elsif !table.nil?
        fields.merge!(table.rows_hash)
      end
      fields.each do |field, value|
        value = "" if value == "<blank>"
        case field
        when 'Email', 'Password', 'Password confirmation', 'First name', 'Last name', 'Preferred name'
          fill_in field, :with => value
        when 'What County', 'Preferred language', 
          'What is your primary role within the health department', 
          'Are you with any of these organizations'
            select Regexp.new(value), :from => field
        else
          raise "Unknown field: #{field}: Please update this step if you intended to use this field."
        end
      end
    end
  end
end

World(FeatureHelpers::FillInMethods)
