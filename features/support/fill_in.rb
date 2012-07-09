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
       "Preferred language"=> "English"
      }
      
      table = table.nil? ? {} : table.is_a?(Hash) ? table : table.rows_hash 
      table.merge!(fields){|k, v1, v2| v1 || v2 } # merge into table so we can maintain the order of insertion
      
      fill_in_signup_form(table)
    end
    
    def fill_in_signup_form(fields = {})
      fields = fields.is_a?(Hash) ? fields : fields.rows_hash
      fields.each do |field, value|
        value = "" if value == "<blank>"
        case field
        when 'Email', 'Password', 'Password Confirmation', 'First Name', 'Last Name', 'Preferred name'
          fill_in field, :with => value
        when 'Preferred language', "Home Jurisdiction", "Role"
          find_field(field).select(value.strip)
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
