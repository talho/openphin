class Service::Talho::Console::Message
  extend PropertyObject::ClassMethods
  include PropertyObject::InstanceMethods
  include Validatable
  
  property :message
  property :user
  
  def perform_delivery
  end
  
  def title
    message.Messages.select {|m| m.name == 'title' }.first.Value
  end
  
  def rendered_message
    recipient = message.Recipients.select {|r| r.id == self.user.id.to_s }.first
    device = recipient.Devices.select{|d| d.device_type == 'Console'}.first
    message_hash = {}
    device.Messages.each do |msg|
      message_hash[msg.name] = {:ref => msg.ref, :value => msg.Value}
    end
    build_ivr(message_hash)
  end
  
  def author
    if message.Author
      "#{message.Author.display_name} - #{message.Author.Contacts.select {|c| c.device_type == 'E-mail'}.first.Value}"
    else 
      ''
    end
  end
  
  private
  
  def build_ivr(message_hash)
    msg = ''
    provider = message.Behavior.Delivery.Providers.select{|p| p.device == 'Console' && p.name == 'talho'}.first
    ivr_name = provider.ivr
    @ivr = message.IVRTree.select{|ivr| ivr.name == ivr_name}.first
    if @ivr.nil?
      begin
        message_name = message.Behavior.Delivery.Providers.select{|p| p.device == 'Console'}.first.Messages.select{|m| m.name == "message"}.first.ref
      rescue
        message_name = 'message'
      end
      
      if message_hash[message_name]
        message_name = message_hash[message_name]
      elsif message_hash['message']
        message_name = message_hash['message']
      end
      p message_name
      return message.Messages.select{|m| m.name == message_name}.first.Value
    end
    
    @ivr.ContextNodes.each do |ctxt|
      case ctxt.operation
        when 'put', 'TTS'
          ctxt.responses.each do |resp|
            msg += get_text_response(resp, message_hash)
          end
      end
    end
    
    msg
  end
  
  def get_text_response(resp, message_hash)
    unless resp.ref.blank?
      if message_hash[resp.ref]
        return message_hash[resp.ref][:value] if message_hash[resp.ref][:value]
        return message.Messages.select{|m| m.name == message_hash[resp.ref][:ref]}.first.Value unless message_hash[resp.ref][:ref].blank? # check for blank as m.name will never be blank
      else
        return message.Messages.select{|m| m.name == resp.ref}.first.Value
      end
    else
      return resp.value
    end
    '' # return an empty string if we get to this point.
  end
end 