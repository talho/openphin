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
Role.seed_many(:name, [
  {:name => Role::ADMIN, :approval_required => false, :user_role => false}
])