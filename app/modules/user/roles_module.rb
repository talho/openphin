
module User::RolesModule
  def self.included(base)
    base.has_many :role_memberships, :include => [:jurisdiction, :role], :dependent => :delete_all
    base.has_many :role_requests, :dependent => :delete_all, :include => [:jurisdiction, :role]
    base.accepts_nested_attributes_for :role_requests, :organization_membership_requests
    base.has_many :roles, :through => :role_memberships, :uniq => true
    
    base.has_many :apps, :through => :roles, :uniq => true, :conditions => "apps.name != 'system'"
    
    base.validates_associated :role_requests
    base.validates_associated :role_memberships
    
    base.attr_accessible :role_requests_attributes
      
    base.after_create :assign_public_role
    
    base.scope :with_role, lambda {|role|
      role = role.is_a?(Role) ? role : Role.find_by_name(role)
      { :conditions => [ "role_memberships.role_id = ?", role.id ], :include => :role_memberships}
    }
    base.scope :without_role, lambda {|role|
      role = role.is_a?(Role) ? role : Role.find_by_name(role)
      { :conditions => [ "users.id not in (select user_id from role_memberships where role_id = ?)", role.id ], :include => :role_memberships}
    }
  end

  def self.assign_role(role, jurisdiction, users)
    users.each do |u|
      u.role_memberships.create(:role => role, :jurisdiction => jurisdiction) unless u.role_memberships.map(&:role_id).include?(role.id) && u.role_memberships.map(&:jurisdiction_id).include?(jurisdiction.id)
    end
  end
  
  def self.with_roles(roles)
    roles = roles.map{|role| role.is_a?(Role) ? role : Role.find_by_name(role)}
    where(["role_memberships.role_id in (?)", roles.map(&:id)]).includes(:role_memberships)
  end
  
  def is_sysadmin?
    return role_memberships.count(:conditions => { :role_id => Role.sysadmin.id } ) > 0
  end
  
  def is_super_admin?(app = "")
    return true if is_sysadmin?
    conditions = app.blank? ? {} : {"apps.name" => app}
    return role_memberships.joins(:role => :app).where(['role_id in (?)', Role.superadmins.find(:all, :conditions => conditions).map(&:id)]).count(:conditions => {  } ) > 0
  end
   
  def is_admin?(app = "")
    # TODO: Should be app agnostic
    return true if is_sysadmin?
    return true if is_super_admin?(app)
    conditions = app.blank? ? {} : {"apps.name" => app}
    return role_memberships.joins(:role => :app).count( :conditions => { :role_id => Role.admins.find(:all, :conditions => conditions).map(&:id)} ) > 0
  end
  
  def is_admin_for?(other, app = "")
    # TODO: Role.admin should check on role/app for the jurisdiction
    return true if self.is_sysadmin? || self.is_super_admin?
    if other.class == Jurisdiction
      return true if role_memberships.find(:all, :conditions => {:role_id => Role.admins(app).map(&:id)}).detect{|r| other.is_or_is_descendant_of?(r.jurisdiction)}
    elsif other.class == Array || other.class == ActiveRecord::NamedScope::Scope
      other.each do |jurisdiction|
        return true if role_memberships.find(:all, :conditions => {:role_id => Role.admins(app).map(&:id)}).detect{|r| jurisdiction.is_or_is_descendant_of?(r.jurisdiction)}
      end
    end
    false
  end
   
  def is_org_approver?(app = "phin")
    return role_memberships(true).count(:conditions => { :role_id => Role.org_admin(app).id } ) > 0
  end

  def has_role?(role_sym, app = '')
    self.roles.joins(:app).where("roles.name ~* ?", role_sym.to_s.titleize).where(app != "" ? {"apps.name" => app.to_s} : "").exists?
  end

  def enabled_applications
    return current_user.roles.map(&:application).flatten
  end

  def has_non_public_role?(app = '')
    res = self.roles.where(public: false)
    res = res.joins(:app).where('apps.name' => app.to_s) unless app.blank?
    res.exists?
  end

  def has_public_role?
    self.roles.where(public: true).exists?
  end

  def has_public_role_in?(jurisdiction)
    return role_memberships.count(:conditions => ["role_id = ? AND jurisdiction_id = ?", Role.public.id, j.id]) > 0
  end

  def has_public_role_request?
    return role_requests.count(:conditions => ["role_id = ?", Role.public.id]) > 0
  end

  def has_app?(app)
    self.roles.joins(:app).where("apps.name" => app.to_s).exists?
  end
  alias_method :has_application?, :has_app?
    
  def visible_actors  #this is an ugly solution - returns every user in the system that a given user has rights to see.
    return User.without_role("SysAdmin").with_apps( roles.where(name: [Role::Defaults[:admin], Role::Defaults[:superadmin]]).map(&:app).uniq )
  end
      
  def alerter?
    !role_memberships.alerter.empty?
  end
      
  def handle_role_requests(req_json, current_user)
    return [ false, [ "Permission denied" ] ] unless editable_by?(current_user)
    rq_list = ActiveSupport::JSON.decode(req_json)
    result = "success"
    rq_errors = []

    ActiveRecord::Base.transaction {
      rq_list.find_all{|rq| rq["state"]=="deleted" && rq["id"] > 0}.each { |rq|
        rqType = (rq["type"]=="req") ? RoleRequest : RoleMembership
        rq_to_delete = rqType.find(rq["id"])
        if rq_to_delete && self == rq_to_delete.user
          rq_to_delete.destroy
        else
          rq_errors.concat(rq_to_delete.errors.full_messages)
        end
      }
      rq_list.find_all{|rq| rq["state"]=="new"}.each { |rq|
        existing_rq = role_requests.find_by_role_id_and_jurisdiction_id(rq["role_id"], rq["jurisdiction_id"])
        if existing_rq && current_user.is_admin_for?(self.jurisdictions)
          existing_rq.approve!(current_user)
        else
          role_request = RoleRequest.new
          role_request.jurisdiction_id = rq["jurisdiction_id"]
          role_request.role_id = rq["role_id"]
          role_request.requester = current_user
          role_request.user = self
          if role_request.valid? && role_request.save
            
          else
            result = "failure"
            rq_errors.concat(role_request.errors.full_messages)
          end
        end
      }

      if self.role_memberships.public_roles.empty?
        result = "rollback"
        rq_errors.push("You must have at least one public role.  Please add a public role and re-save.")
        raise ActiveRecord::Rollback
      end
    }

    [ result, rq_errors ]
  end
  
  private
  
  def assign_public_role
    # If they don't have the phin public role for their home_jurisdiciton, then add it. Rely on the user creator or the "get more apps" manager to add public roles for other apps.
    pub = Role.joins(:app).where(public: true, "apps.name" => 'phin').first
    self.role_memberships.create(role_id: pub.id, jurisdiction_id: (self.home_jurisdiction || pub.app.root_jurisdiction || Jurisdiction.first).id)
  end
end
