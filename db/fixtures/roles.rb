require 'csv'

CSV.open(File.dirname(__FILE__) + '/roles.csv', :headers => true) do |roles|
  roles.each do |row|
    Role.find_or_create_by_name(:name => row['role']) { |role|
      role.approval_required = row['approval_required'].downcase == 'true'
      role.alerter = row['alerter']
      role.app_id = App.find_by_name(row['application'])
    }
  end
end

# System-roles
# Post file-in to assure there setting from file-in overwrites
Role.admin
Role.superadmin
Role.sysadmin
Role.org_admin

public = Role.public
public.public = true
public.save