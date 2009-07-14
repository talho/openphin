When "I fill out the alert form with:" do |table|
  table.rows_hash.each do |key, value|
    case key
    when "People"
      user = Given "a user named #{value}"
      fill_in 'alert_recipient_id', :with => user.id
    when 'Status'
      select value, :from => key
    else
      fill_in key, :with => value
    end
  end
end