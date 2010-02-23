Organization.find_or_create_by_name(:name => "TALHO") { |o|
  o.approved = true
  o.description = "Texas Association of Local Health Officials"
  o.street = "715 Discovery Blvd. Ste. 308"
  o.locality = "Cedar Park"
  o.state = "TX"
  o.postal_code = "78613"
  o.phone = "5125289691"
  o.distribution_email = "admins@talho.org"
  o.contact = User.find_by_email("jason@texashan.org")
  o.email_confirmed = true
  o.queue = 'redcross'
}