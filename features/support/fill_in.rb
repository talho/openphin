module FeatureHelpers
  module FillInMethods
    
    def fill_in_user_signup_form(table=nil)
      fields={"Email"=> "john@example.com",
       "Password"=> "password",
       "Password confirmation"=> "password",
       "First name"=> "John",
       "Last name"=> "Smith",
       "Preferred name"=> "Jonathan Smith",
       "Are you with any of these organizations"=> "Red Cross",
       "What County"=> "Dallas County",
       "What is your primary role"=> "Health Alert and Communications Coordinator",
       "Preferred language"=> "English"
      }
      
      if table.is_a?(Hash)
        fields.merge!(table)
      elsif !table.nil?
        fields.merge!(table.rows_hash)
      end
      
      fill_in_signup_form(fields)
    end
    
    def fill_in_signup_form(table = nil)
      fields = {}
      if table.is_a?(Hash)
        fields.merge!(table)
      elsif !table.nil?
        fields.merge!(table.rows_hash)
      end
      fields.each do |field, value|
        value = "" if value == "<blank>"
        case field
        when 'Email', 'Password', 'Password confirmation', 'First name', 'Last name', 'Preferred name', 'Street', 'City', 'State', 'Zip', 'Organization', 'Phone', 'Fax', 'Description', 'Please describe your role', 'Distribution Email', 'Name', 'Email Address', 'Phone Number'
          fill_in field, :with => value
        when 'What County', 'Preferred language', 
          'What is your primary role', 
          'Are you with any of these organizations', 'Organization Type'
            select Regexp.new(value), :from => field
        when /Counties/
          select_multiple value.split(',').map(&:strip), :from => 'organization_jurisdiction_ids'
        when "Are you a public health professional?"
          id = "health_professional"
          if value == '<unchecked>'
            uncheck id
          else
            check id
          end
        else
          raise "Unknown field: #{field}: Please update this step if you intended to use this field."
        end
      end
    end
  
    def fill_in_alert_form(table = nil)
      fields = { 
        "Title" => "H1N1 SNS push packs to be delivered tomorrow",
        "Message" => "For more details, keep on reading...",
        "Severity" =>"Moderate",
        "Status" => "Actual",
        "Acknowledge"  => "<unchecked>",
        "Communication methods" => "E-mail",
        "Delivery Time" => "15 minutes"
      }

      if table.is_a?(Hash)
        fields.merge!(table)
      elsif !table.nil?
        fields.merge!(table.rows_hash)
      end
      
      fields.each do |label, value|
        fill_in_alert_field label, value
      end
    end
  
    def fill_in_alert_field(label, value)
      case label
      when "People"
        value.split(',').each do |name| 
          user = Given "a user named #{name.strip}"
          fill_in 'alert_user_ids', :with => user.id.to_s
        end
      when 'Status', 'Severity', 'Jurisdiction', 'Delivery Time'
        select value, :from => label
      when 'Acknowledge', 'Sensitive'
        id = "alert_#{label.parameterize('_')}"
        if value == '<unchecked>'
          uncheck id
        else
          check id
        end
      when 'Communication methods'
        check value
      when /Jurisdictions/, /Role[s]?/, /Organization[s]?/
        value.split(',').map(&:strip).each{ |r| check r }
      when "Message Recording"
        attach_file(:alert_message_recording, File.join(RAILS_ROOT, 'features', 'fixtures', value), "audio/x-wav")
      when "Message", "Title"
        fill_in label, :with => value
      else
        raise "Unexpected: #{label} with value #{value}. You may need to update this step."
      end
    end

    def fill_in_assign_role_form(table)
      table.rows_hash.each do |label, value|
        case label
        when "People"
          value.split(',').each do |name| 
            user = Given "a user named #{name.strip}"
            fill_in "role_assigns_user_ids", :with => user.id.to_s
          end
        when "Role", "Jurisdiction"
          select value.split(',').map(&:strip), :from => label
        else
          raise "Unknown field '#{label}'. You may need to update this step."
        end
      end
    end


  end

end

World(FeatureHelpers::FillInMethods)
