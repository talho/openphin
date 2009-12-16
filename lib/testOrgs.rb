    newOrgs=File.open(File.dirname(__FILE__) +  '/../db/fixtures/orglist.csv').read.split("\n").map{|row| row.split("|")}
    newOrgs.each{|o| print o
    x = Array.new
                 }


   myOrg = Organization.find_or_create_by_name(:name => "TALHO") { |o|
  o.organization_type = Organization.find_by_name('Non-profit')
  o.approved = true
  o.description = "Texas Association of Local Health Officials"
  o.street = "715 Discovery Blvd. Ste. 308"
  o.locality = "Cedar Park"
  o.state = "TX"
  o.postal_code = "78613"
  o.phone = "5125289691"
  o.distribution_email = "admins@talho.org"
  o.contact_display_name = "Jason Phipps"
  o.contact_email = "jason@texashan.org"
  o.contact_phone = "5125289691"
  o.email_confirmed = true
  o.queue = 'redcross'}
      


