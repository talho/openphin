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

class Service::Swn::Invitation < Service::Swn::Base
  load_configuration_file Rails.root.to_s+"/config/swn.yml"
  load_configuration_file Rails.root.to_s+"/config/email.yml"

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

    initialize_fake_delivery(@config) if @config.fake_delivery?

    body = Service::Swn::Email::Invitation.new(
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

    initialize_fake_delivery(@config) if @config.fake_delivery?
    
    @invitation.body = "You have been made a member of the organization #{@invitation.default_organization.name}."

    body = Service::Swn::Email::Invitation.new(
      :invitation => @invitation,
      :users => @users,
      :username => @config['username'],
      :password => @config['password'],
      :retry_duration => @config['retry_duration']
    ).build!

    perform_delivery body
  end

  private

  def initialize_fake_delivery(config) # :nodoc:
    Service::Swn::Invitation.instance_eval do
      define_method(:perform_delivery) do |body|
        Service::Swn::Invitation.deliveries << OpenStruct.new(:body => body)
        config.options[:default_response] ||= "200 OK"
      end
    end
  end
end
