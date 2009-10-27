require 'fastercsv'

FasterCSV.open(File.dirname(__FILE__) + '/roles.csv', :headers => true) do |roles|
  roles.each do |row|
    Role.seed(:name, :approval_required) do |role|
      role.name = row['role']
      role.approval_required = row['approval_required'].downcase == 'true'
      role.alerter = row['alerter']
    end
  end
end

# System-roles
# Post file-in to assure there setting from file-in overwrites
Role.admin
Role.superadmin
Role.org_admin
Role.seed_many(:name, [
  {:name => "Rollcall",                   :approval_required => true, :user_role => false}
])