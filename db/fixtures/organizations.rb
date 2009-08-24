Organization.seed(:name) do |o|
  o.name = 'Red Cross'
  o.organization_type = Organization.find_by_name('Non-profit')
  o.approved = true
  o.description = "National Organization"
  o.street = "123 Willow Ave. Suite 34"
  o.locality = "Dallas"
  o.state = "TX"
  o.postal_code = "22212"
  o.phone = "5551234567"
  o.distribution_email = "red_cross@email.com"
  o.contact_display_name = "Bob Dole"
  o.contact_email = "bob@example.com"
  o.contact_phone = "5121234567"
  o.email_confirmed = true
end
