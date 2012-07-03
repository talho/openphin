class ChangeNonPublicPhinRolesToNonPublicHanRoles < ActiveRecord::Migration
  def up
    roles = Role.arel_table
    public_phin_role = roles[:name].eq('Public').and(roles[:application].eq('phin'))
    public_han_role = roles[:name].eq('Public').and(roles[:application].eq('han'))
    public_han_role_id = Role.where(public_han_role).pluck(:id).first

    User.joins(:role_memberships).joins(:roles).where(public_phin_role).uniq.each do |u|
      u.role_memberships.where(public_phin_role).each do |rm|
        rm.update_attribute(:role_id,public_han_role_id)
      end
    end
  end

  def down
    roles = Role.arel_table
    public_phin_role = roles[:name].eq('Public').and(roles[:application].eq('phin'))
    public_phin_role_id = Role.where(public_phin_role).pluck(:id).first
    public_han_role = roles[:name].eq('Public').and(roles[:application].eq('han'))

    User.joins(:role_memberships).joins(:roles).where(public_han_role).uniq.each do |u|
      u.role_memberships.where(public_han_role).each do |rm|
        rm.update_attribute(:role_id,public_phin_role_id)
      end
    end
  end

end

# inspect
#User.joins(:role_memberships).joins(:roles).all.uniq.each do |u|
#  u.role_memberships.each{|rm| puts "#{u.role_memberships.map(&:role_id)}: #{u.display_name} is #{rm.role.name} in #{rm.jurisdiction.name} of #{rm.role.application} "}
#end


