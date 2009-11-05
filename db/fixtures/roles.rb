require 'fastercsv'

FasterCSV.open(File.dirname(__FILE__) + '/roles.csv', :headers => true) do |roles|
  roles.each do |row|
    Role.find_or_create_by_name(:name => row['role']) { |role|
      role.approval_required = row['approval_required'].downcase == 'true'
      role.alerter = row['alerter']
    }
  end
end

# System-roles
# Post file-in to assure there setting from file-in overwrites
Role.admin
Role.superadmin
Role.org_admin
Role.find_or_create_by_name(:name => "Rollcall") { |role|
  role.approval_required = true
  role.user_role = false
}
