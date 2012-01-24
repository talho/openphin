
module UserModules
  module Roles
    def self.included(base)
      base.has_many :role_memberships, :include => [:jurisdiction, :role], :dependent => :delete_all
      base.has_many :role_requests, :dependent => :delete_all, :include => [:jurisdiction, :role]
      base.accepts_nested_attributes_for :role_requests, :organization_membership_requests
      base.has_many :roles, :through => :role_memberships, :uniq => true
      
      base.validates_associated :role_requests
      base.validates_associated :role_memberships
      
      base.attr_accessible :role_requests_attributes
        
      base.after_create :assign_public_role
      
      base.named_scope :with_role, lambda {|role|
        role = role.is_a?(Role) ? role : Role.find_by_name(role)
        { :conditions => [ "role_memberships.role_id = ?", role.id ], :include => :role_memberships}
      }
      base.named_scope :without_role, lambda {|role|
        role = role.is_a?(Role) ? role : Role.find_by_name(role)
        { :conditions => [ "users.id not in (select user_id from role_memberships where role_id = ?)", role.id ], :include => :role_memberships}
      }
      base.named_scope :with_roles, lambda {|roles|
        roles = roles.map{|role| role.is_a?(Role) ? role : Role.find_by_name(role)}
        { :conditions => [ "role_memberships.role_id in (?)", roles.map(&:id) ], :include => :role_memberships}
      }
    end
          
    def self.assign_role(role, jurisdiction, users)
      users.each do |u|
        u.role_memberships.create(:role => role, :jurisdiction => jurisdiction) unless u.role_memberships.map(&:role_id).include?(role.id) && u.role_memberships.map(&:jurisdiction_id).include?(jurisdiction.id)
      end
    end
    
    def is_sysadmin?
      return role_memberships.count(:conditions => { :role_id => Role.sysadmin.id } ) > 0
    end
    
    def is_super_admin?(app = "")
      return true if is_sysadmin?
      begin
        jid = Jurisdiction.state.nonforeign.blank? ? 0 : Jurisdiction.state.nonforeign.first.id # Should be Texas
        rescue
          return false
        end
        return false if jid.nil?
        conditions = app.blank? ? {} : {:application => app}
        return role_memberships.count(:conditions => { :role_id => Role.superadmins.find(:all, :conditions => conditions).map(&:id), :jurisdiction_id => jid } ) > 0
      end
     
    def is_admin?(app = "")
      # TODO: Should be app agnostic
      return true if is_sysadmin?
      return true if is_super_admin?(app)
      conditions = app.blank? ? {} : {:application => app}
      return role_memberships.count( :conditions => { :role_id => Role.admins.find(:all, :conditions => conditions).map(&:id)} ) > 0
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
      roles.any? { |r| r.name.to_s.titleize == role_sym.to_s.titleize && (app == '' || r.application.to_s.titleize == app.to_s.titleize) }
    end
  
    def has_application?(app_sym)
      roles.any? { |r| r.application.to_s.titleize == app_sym.to_s.titleize }
    end
  
    def enabled_applications
      return current_user.roles.map(&:application).flatten
    end
  
    def has_non_public_role?
      self.roles.non_public.size > 0
    end
  
    def has_public_role?
      self.roles.public.size > 0
    end
  
    def has_public_role_in?(jurisdiction)
      return role_memberships.count(:conditions => ["role_id = ? AND jurisdiction_id = ?", Role.public.id, j.id]) > 0
    end
  
    def has_public_role_request?
      return role_requests.count(:conditions => ["role_id = ?", Role.public.id]) > 0
    end
  
    def has_app?(app)
      self.roles.for_app(app).size > 0
    end
  
    def apps
      return self.roles.map(&:application).uniq
    end
  
    def visible_actors  #this is an ugly solution - returns every user in the system that a given user has rights to see.
      return User.without_role("SysAdmin").without_apps( Role.all.map(&:application).uniq - apps )
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
              RoleRequestMailer.deliver_user_notification_of_role_request(role_request) if !role_request.approved?
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
      # bail out if they have any roles/rolerequests for application other than phin
      return unless ( role_requests.map(&:role) + role_memberships.map(&:role) ).map(&:application).uniq.reject{|a| a=='phin'}.blank?
  
      public_role = Role.public
      if (role_requests.blank? && role_memberships.blank?) || (!role_requests.map(&:role_id).flatten.include?(public_role.id) && !role_memberships.map(&:role_id).flatten.include?(public_role.id))
        if(role_requests.blank? && role_memberships.blank?)
          role_memberships.create!(:role => public_role, :jurisdiction => Jurisdiction.state.nonforeign.first) unless Jurisdiction.state.nonforeign.empty?
        else
          rr = role_requests
          rr.each do |request|
            role_memberships.create!(:role => public_role, :jurisdiction => request.jurisdiction)
            request.destroy if request.role == public_role
          end unless role_requests.nil? || role_memberships.public_roles.count != 0
          role_memberships.each do |request|
            role_memberships.create!(:role => public_role, :jurisdiction => request.jurisdiction)
          end if role_memberships.public_roles.count == 0
        end
  
        role_requests.find_all_by_role_id(public_role).each do |request|
          if request.approver.nil?
            role_memberships.create!(
              :role => public_role,
              :jurisdiction => request.jurisdiction
            )
          end
          request.destroy
        end
  
        if self.role_requests.any?
          self.role_memberships.find_or_create_by_role_id_and_jurisdiction_id(
            public_role.id,
            self.role_requests.first.jurisdiction.id
          )
        end
      end
    end
  end
end