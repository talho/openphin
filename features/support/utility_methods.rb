module FeatureHelpers
  module UtilityMethods
    def true_or_false(value)
      return true if value =~ /yes/i
      false
    end
    
    def find_email(email_address, table=nil)
      When "delayed jobs are processed"
      ActionMailer::Base.deliveries.detect do |email|
        status = false
        if(!email.bcc.blank?)
          status ||= email.bcc.include?(email_address)
        end
        if(!email.to.blank?)
          status ||= email.to.include?(email_address)
        end

        unless table.nil?
          table.rows.each do |row|
            field, value = row.first, row.last

            case field
            when /subject/
              status &&= email.subject =~ /#{Regexp.escape(value)}/
            when /body contains$/
              status &&= email.body =~ /#{Regexp.escape(value)}/
            when /body does not contain$/
              status &&= !(email.body =~ /#{Regexp.escape(value)}/)
            when /body contains alert acknowledgment link/
              attempt = User.find_by_email(email_address).alert_attempts.last
              if value.blank?
                status &&= email.body.include?(email_acknowledge_alert_url(attempt.alert, :call_down_response => 0, :host => HOST))
              else
                call_down_response = attempt.alert.becomes(HanAlert).reload.call_down_messages.index(value).to_i
                status &&= email.body.include?(email_acknowledge_alert_url(attempt.alert, :call_down_response => call_down_response, :host => HOST))
              end
            when /body does not contain alert acknowledgment link/
              attempt = User.find_by_email(email_address).alert_attempts.last
              status &&= !email.body.include?(email_acknowledge_alert_url(attempt, :host => HOST, :call_down_response => 0))
            when /attachments/
              filenames = email.attachments
              status &&= !filenames.nil? && value.split(',').all?{|m| filenames.map(&:original_filename).include?(m) }
            else
              raise "The field #{field} is not supported, please update this step if you intended to use it."
            end
          end
        end
        status
      end
    end

    def find_email_via_SWN(email_address, table=nil)
      When "delayed jobs are processed"
      Service::Email.deliveries.detect do |email|
        xml = Nokogiri::XML(email.body)
        status = false
        status ||= (xml.search('//swn:rcpts/swn:rcpt/swn:contactPnts/swn:contactPntInfo[@type="Email"]/swn:address',
                {"swn" => "http://www.sendwordnow.com/notification"})).map(&:inner_text).include?(email_address)
        unless table.nil?
          table.rows.each do |row|
            field, value = row.first, row.last

            case field
            when /subject/
              status &&= (xml.search('//swn:SendNotificationInfo/swn:notification/swn:subject',
                {"swn" => "http://www.sendwordnow.com/notification"})).map(&:inner_text).first =~ /#{Regexp.escape(value)}/
            when /body contains$/
              status &&= email.body =~ /#{Regexp.escape(value)}/
            when /body does not contain$/
              status &&= !(email.body =~ /#{Regexp.escape(value)}/)
            when /body contains alert acknowledgment link/
              attempt = User.find_by_email(email_address).alert_attempts.last
              if value.blank?
                status &&= (xml.search('//swn:SendNotificationInfo/swn:gwbText',
                  {"swn" => "http://www.sendwordnow.com/notification"})).map(&:inner_text).first =~ /#{Regexp.escape("Please press one to acknowledge this alert.")}/
              else
                call_down_response = attempt.alert.becomes(HanAlert).reload.call_down_messages.index(value).to_i
                status &&= (xml.search('//swn:SendNotificationInfo/swn:gwbText',
                  {"swn" => "http://www.sendwordnow.com/notification"})).map(&:inner_text)[call_down_response-1] =~ /#{Regexp.escape(value)}/
              end
            when /body does not contain alert acknowledgment link/
              attempt = User.find_by_email(email_address).alert_attempts.last
              if value.blank?
                status &&= (xml.search('//swn:SendNotificationInfo/swn:gwbText',
                  {"swn" => "http://www.sendwordnow.com/notification"})).empty?
              else
                call_down_response = attempt.alert.becomes(HanAlert).reload.call_down_messages.index(value).to_i
                status &&= !(xml.search('//swn:SendNotificationInfo/swn:gwbText',
                  {"swn" => "http://www.sendwordnow.com/notification"})).map(&:inner_text)[call_down_response-1] =~ /#{Regexp.escape(value)}/
              end
            when /attachments/
              filenames = email.attachments
              status &&= !filenames.nil? && value.split(',').all?{|m| filenames.map(&:original_filename).include?(m) }
            else
              raise "The field #{field} is not supported, please update this step if you intended to use it."
            end
          end
        end
        status
      end
    end

    def destroy_link_onclick(confirm_message)
      "elem.setAttribute('onclick',\"if (#{confirm_message}) { var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);f.submit(); };return false;\"); "
    end
  end
end

World(FeatureHelpers::UtilityMethods)
