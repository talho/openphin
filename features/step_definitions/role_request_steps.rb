When /^I fill out the role request form with:$/ do |table|
  table.rows_hash.each do |label, value|
    case label
    when /Jurisdiction/i, /Role/i
      select value, :from => label
    else
      raise "The field '#{field}' is not supported, please update this step if you intended to use it"
    end
  end
  click_button 'Submit Request'
end

Then /^I should see that I have a pending role request$/ do
  current_user.role_requests.should_not be_empty
end