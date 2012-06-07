class AddPublicHanRoleToExistingPhinUsers < ActiveRecord::Migration
  def up
    roles = Role.arel_table
    public_role_id = Role.where(:name=>"Public",:application=>"phin").pluck(:id).first
    public_phin_role = roles[:name].not_eq('Public').and(roles[:application].eq('phin'))
    User.joins(:role_memberships).joins(:roles).where(public_phin_role).uniq.each do |u|
      jurisdiction_id = u.role_memberships.first.jurisdiction_id
      unless u.role_memberships.exists?(public_role_id)
        u.role_memberships.create(:role_id=>public_role_id,:jurisdiction_id=>jurisdiction_id)
#        u.role_memberships.each{|rm| puts "#{u.role_memberships.map(&:role_id)}: #{u.display_name} is #{rm.role.name} in #{rm.jurisdiction.name} of #{rm.role.application} "}
      end
    end
  end

  def down
    role_id = Role.where(:name=>"Public",:application=>"han").pluck(:id).first
    RoleMembership.where(:role_id=>role_id).delete_all
  end
end
