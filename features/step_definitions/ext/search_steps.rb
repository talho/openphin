When /^I search for a user with the following:$/ do |fields|
  step %(I press "Reset")
  fields.rows.each do |field|
    key, value = field
    case key
      when /Roles?/,/Jurisdictions?/
        item = (key =~ /Roles?/) ? "rol" : "jur"
        value.split(",").each do |v|
          step %Q(I click #{item}-list-item "#{v}")
        end
      else
        step %Q(I fill in "#{key}" with "#{value}")
    end
  end
  step %(I press "Search")
end


