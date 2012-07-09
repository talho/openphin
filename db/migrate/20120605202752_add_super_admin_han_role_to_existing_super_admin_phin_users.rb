class AddSuperAdminHanRoleToExistingSuperAdminPhinUsers < ActiveRecord::Migration
  def up
    roles = Role.arel_table
    super_admin_phin_role = roles[:name].eq('SuperAdmin').and(roles[:application].eq('phin'))
    super_admin_han_role_id = Role.where(:name=>"SuperAdmin",:application=>"han").pluck(:id).first


    User.joins(:role_memberships).joins(:roles).where(super_admin_phin_role).uniq.each do |u|
      jurisdiction_id = u.role_memberships.first.jurisdiction_id
      u.role_memberships.create(:role_id=>super_admin_han_role_id,:jurisdiction_id=>jurisdiction_id)
#       u.role_memberships.each{|rm| puts "#{u.role_memberships.map(&:role_id)}: #{u.display_name} is #{rm.role.name} in #{rm.jurisdiction.name} of #{rm.role.application} "}
    end
  end

  def down
    role_id = Role.where(:name=>"SuperAdmin",:application=>"han").pluck(:id).first
    RoleMembership.where(:role_id=>role_id).delete_all
  end
end
