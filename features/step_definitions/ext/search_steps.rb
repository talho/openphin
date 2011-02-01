When /^I search for a user with the following:$/ do |fields|
  And %(I press "Reset")
  fields.rows.each do |field|
    key, value = field
    case key
      when /Roles?/,/Jurisdictions?/
        item = (key =~ /Roles?/) ? "rol" : "jur"
        value.split(",").each do |v|
          And %Q(I click #{item}-list-item "#{v}")
        end
      else
        And %Q(I fill in "#{key}" with "#{value}")
    end
  end
  And %(I press "Search")
end


