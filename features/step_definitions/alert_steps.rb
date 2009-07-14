When "I fill out the alert form with:" do |table|
  table.rows_hash.each do |key, value|
    case key
    when "People"
      user = Given "a user named #{value}"
      fill_in 'alert_user_id', :with => user.id
    when 'Status', 'Severity'
      select value, :from => key
    when 'Acknowledge'
      if value == '<unchecked>'
        uncheck 'alert_acknowledge'
      else
        check 'alert_acknowledge'
      end
    when 'Communication methods'
      check value
    else
      fill_in key, :with => value
    end
  end
end
