# == Schema Information
#
# Table name: invitations
#
#  id              :integer(4)      not null, primary key
#  name            :string(255)
#  body            :text
#  organization_id :integer(4)
#  author_id       :integer(4)
#  subject         :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Service::SWN::Invitation < Service::SWN::Base
  def initialize(invitation, config, users)
    @invitation, @config, @users = invitation, config, users
  end

  def deliver
    SWN_LOGGER.info <<-EOT.gsub(/^\s+/, '')
      |Building invitation message:
      |  invitation: #{@invitation.id}
      |  user_ids: #{@users.map(&:id).inspect}
      |  config: #{@config.options.inspect}
    EOT

    body = Service::SWN::Email::Invitation.new(
      :invitation => @invitation,
      :users => @users,
      :username => @config['username'],
      :password => @config['password'],
      :retry_duration => @config['retry_duration']
    ).build!

    perform_delivery body
  end

  def deliver_org_membership_notification
    SWN_LOGGER.info <<-EOT.gsub(/^\s+/, '')
      |Building invitation message:
      |  invitation: #{@invitation.id}
      |  user_ids: #{@users.map(&:id).inspect}
      |  config: #{@config.options.inspect}
    EOT

    @invitation.body = "You have been made a member of the organization #{@invitation.default_organization.name}."

    body = Service::SWN::Email::Invitation.new(
      :invitation => @invitation,
      :users => @users,
      :username => @config['username'],
      :password => @config['password'],
      :retry_duration => @config['retry_duration']
    ).build!

    perform_delivery body
  end
end
