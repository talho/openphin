class RoleRequest < ActiveRecord::Base

end
class AddUserToRoleRequest < ActiveRecord::Migration
  def self.up

    add_column :role_requests, :user_id, :integer
    RoleRequest.all.each do |rr|
      rr.user_id = rr.requester_id
      rr.save
    end
  end

  def self.down
    add_column :role_requests, :user_id, :integer
    RoleRequest.all.each do |rr|
      rr.requester_id = rr.requester_id
      rr.save
    end
  end
end
