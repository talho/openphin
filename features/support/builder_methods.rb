module FeatureHelpers
  module BuilderMethods
    def create_alert_with(attributes)
      attributes['from_jurisdiction'] = Jurisdiction.find_by_name(attributes['from_jurisdiction']) unless attributes['from_jurisdiction'].blank?
      attributes['jurisdictions'] = attributes['jurisdictions'].split(',').map{|m| Jurisdiction.find_by_name(m.strip)} unless attributes['jurisdictions'].blank?
      attributes['organizations'] = attributes['organizations'].split(',').map{|m| Organization.find_by_name(m.strip)} unless attributes['organizations'].blank?
      attributes['roles'] = attributes['roles'].split(',').map{|m| Role.find_or_create_by_name(m.strip)} unless attributes['roles'].blank?

      if attributes.has_key?('people')
        attributes['user_ids'] = attributes.delete('people').split(',').map{ |m|
          first_name, last_name = m.split(/\s+/) 
          User.find_by_first_name_and_last_name(first_name, last_name)
        } 
      end
  
      if attributes['author'].blank?
        attributes['author_id'] = current_user.id unless current_user.nil?
      else
        attributes['author_id'] = User.find_by_display_name(attributes.delete('author')).id
      end

      if attributes.has_key?('acknowledge')
        attributes['acknowledge'] = true_or_false(attributes.delete('acknowledge'))
      end

      if attributes.has_key?("communication methods")
        attributes['device_types']= attributes.delete('communication methods').split(",").map{|device_name| "Device::#{device_name}Device"}
      end

      if attributes.has_key?("delivery time")
        delivery_time=attributes.delete("delivery time")
        case delivery_time
          when /72 hours?/i
            attributes['delivery_time']=4320
          when /24 hours?/i
            attributes['delivery_time']=1440
          when /1 hours?/i
            attributes['delivery_time']=60
          when /60 minutes?/i
            attributes['delivery_time']=60
          when /15 minutes?/i
            attributes['delivery_time']=15
        end
      end

      Factory(:alert, attributes)  
    end
  end
end

World(FeatureHelpers::BuilderMethods)