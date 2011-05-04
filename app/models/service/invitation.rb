class Service::Invitation < Service::Base
  def self.deliver_invitation(invitation, config=Service::SWN::Invitation.configuration)
    response = Service::SWN::Invitation.new(invitation, config, invitation.new_invitees).deliver
    response.nil? ? "" : "200 OK"
    #Service::SWN::Email::InvitationNotificationResponse.build(response, invitation)
  end

  def self.deliver_org_membership_notification(invitation, config=Service::SWN::Invitation.configuration)
    response = Service::SWN::Invitation.new(invitation, config, invitation.registered_invitees).deliver_org_membership_notification
    response.nil? ? "" : "200 OK"
    #Service::SWN::Email::InvitationNotificationResponse.build(response, invitation)
  end
end