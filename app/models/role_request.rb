class RoleRequest < ActiveRecord::Base
  validates_presence_of :role_id
  validates_presence_of :requester_id
  
  def requester
    _requester||=PhinPerson.find(:first, :attribute => "externalUID", :value => attributes["requester_id"]) unless attributes["requester_id"].nil?
  end
  def requester=(val)
    self[:requester_id]=val.id unless val.nil? || val.id.nil?
  end
  def approver
    _approver||=PhinPerson.find(:first, :attribute => "externalUID", :value => attributes["approver_id"] ) unless attributes["approver_id"].nil?
  end
  def approver=(val)
    self[:approver_id]=val.id unless val.nil? || val.id.nil?
  end
  def role
    _role||=PhinPerson.find(:first, :attribute => "externalUID", :value => attributes["role_id"] ) unless attributes["role_id"].nil?
  end
  def role=(val)
    self[:role_id]=val.id unless val.nil? || val.id.nil?
  end
end
