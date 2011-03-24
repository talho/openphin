module
FeatureHelpers
  module FillInMethods

    def fill_in_fcbk_control(name, use_email=true)
      if use_email
        user = Given "a user named #{name.strip}"
        name_array = user.email.split("")
      else
        name_array = name.split("")
      end
      div_elem = waiter do
        page.find(".maininput")
      end
      div_elem.should_not be_nil
      div_elem.click
      name_array.each do |c|
        div_elem.set(div_elem.value + c)
        begin
          is_click = waiter do
            page.find("li.outer").click
            true
          end
        rescue
        end
        break if is_click
      end
    end

    def remove_from_fcbk_control(name)
      page.find("a.closebutton").click
      sleep 0.5
    end
    
    def fill_in_user_signup_form(table=nil)
      fields={"Email"=> "john@example.com",
       "Password"=> "Password1",
       "Password Confirmation"=> "Password1",
       "First Name"=> "John",
       "Last Name"=> "Smith",
       "Preferred name"=> "Jonathan Smith",
       "Are you a public health professional?" => '<unchecked>',
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
        when 'Email', 'Password', 'Password Confirmation', 'First Name', 'Last Name', 'Preferred name', 'Street', 'City', 'State', 'Zip', 'Organization', 'Phone', 'Fax', 'Description', 'Please describe your role', 'Distribution Email', 'Name', 'Email Address', 'Phone Number'
          fill_in field, :with => value
        when 'Preferred language'
          find_field(field).select(value.strip)
        when 'What is your primary role',
          'Are you with any of these organizations', 'Organization Type'
          page.check("health_professional")
          find_field(field).select(value.strip)
        when /Jurisdiction of Operation/
          field = find_field("organization_jurisdiction_ids")
          value.split(',').each do |id|
            field.select(id.strip)
          end
        when "Are you a public health professional?"
          id = "health_professional"
          if value == "<unchecked>"
            page.uncheck(id) if find(:css, "##{id}").selected?
          else
            page.check(id) if !find(:css, "##{id}").selected?
          end
        when "Home Jurisdiction"
          value = "" if value.nil?
          find_field("user_role_requests_attributes_0_jurisdiction_id").select(value)
        when "State Jurisdiction"
          find_field(Jurisdiction.find_by_name(value).name).click
        else
          raise "Unknown field: #{field}: Please update this step if you intended to use this field."
        end
      end
    end
  
    def fill_in_audience_form(table)
      table.rows_hash.each do |field, value|
        fill_in_audience_field field, value
      end
    end
    
    def fill_in_audience_field(label, value)
      case label
      when "People"
        value.split(',').each { |name| fill_in_fcbk_control(name) }
      when /Jurisdictions/, /Role[s]?/, /Organization[s]?/, /^Groups?$/
        value.split(',').map(&:strip).each{ |r| check r }
      else
        false
      end
    end

    def fill_in_assign_role_form(table)
      table.rows_hash.each do |label, value|
        case label
        when "People"
          value.split(',').each { |name| fill_in_fcbk_control(name) }
        when "Role", "Jurisdiction"
          value = [value] if value.class == Array
          value.each{|v| v.split(',').map(&:strip).each{|item| select item, :from => label}}
        else
          raise "Unknown field '#{label}'. You may need to update this step."
        end
      end
    end

    def fill_in_group_form(table = nil)
      table.rows_hash.each do |label, value|
        fill_in_group_field label, value
      end
    end

    def fill_in_group_field(label, value)
      case label
      when "Users"
        value.split(',').each { |name| fill_in_fcbk_control(name) }
      when 'Name'
        fill_in "group_#{label.downcase}", :with => value
      when 'Scope'
        select value, :from => "group_#{label.downcase}"
      when /^Jurisdiction[s]$/, /Role[s]?/
        value.split(',').map(&:strip).each{ |r| check r }
      when 'Owner Jurisdiction'
        select value, :from => label
      else
        raise "Unexpected: #{label} with value #{value}. You may need to update this step."
      end
    end
  end

end

World(FeatureHelpers::FillInMethods)
