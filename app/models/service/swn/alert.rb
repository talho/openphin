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

class Service::SWN::Alert < Service::SWN::Base
  def initialize(alert, config, users)
    @alert, @config, @users = alert, config, users
  end

  def deliver
    SWN_LOGGER.info <<-EOT.gsub(/^\s+/, '')
      |Building alert message:
      |  invitation: #{@alert.id}
      |  user_ids: #{@users.map(&:id).inspect}
      |  config: #{@config.options.inspect}
    EOT

    body = Service::SWN::Email::Alert.new(
      :alert => @alert,
      :users => @users,
      :username => @config['username'],
      :password => @config['password'],
      :retry_duration => @config['retry_duration']
    ).build!

    perform_delivery body
  end
end
