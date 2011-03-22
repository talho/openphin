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
  def initialize(alert, config, users, type)
    @alert, @config, @users, @type = alert, config, users, type
  end

  def deliver
    SWN_LOGGER.info <<-EOT.gsub(/^\s+/, '')
      |Building alert message:
      |  invitation: #{@alert.id}
      |  user_ids: #{@users.map(&:id).inspect}
      |  config: #{@config.options.inspect}
    EOT

    body = @type.constantize.new(
      :alert => @alert,
      :users => @users,
      :username => @config['username'],
      :password => @config['password'],
      :retry_duration => @config['retry_duration']
    ).build!

    perform_delivery body
  end

  class AlertNotificationResponse < ActiveRecord::Base
    set_table_name "swn_notification_response"
    belongs_to :alert, :polymorphic => true

    def self.build(response, alert)
      if !alert.blank?
        if !response.blank? && !response['soap:Envelope'].blank? && !response['soap:Envelope']['soap:Header'].blank?
          msg_id = response['soap:Envelope']['soap:Header']['wsa:MessageID']
          self.create!(:alert => alert, :message_id => msg_id)
        else
          self.create!(:alert => alert)
        end
      end
    end
  end
end
