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
Role.seed_many(:name, [
  {:name => Role::Defaults[:admin], :approval_required => false, :user_role => false},
  {:name => Role::Defaults[:org_admin], :approval_required => false, :user_role => false},
  {:name => Role::Defaults[:superadmin], :approval_required => false, :user_role => false}
])