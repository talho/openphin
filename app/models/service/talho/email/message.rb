class Service::Talho::Email::Message < Service::Talho::Email::Base
  property :message
  # this is going to handle the email format. Should build 1 email for each "message" under role names and apply recipients to each
  # send emails for each message to the proper recipients.
  
  # Probably want to have the email message build up an array of hashes like:
  # {:recipients => users, :title => title, :message => message, :from => from}
  # Email message will need to build up the message body via the user's message and the IVRTree. oh the IVRTree
  def perform_delivery
    # find the title, sender, and other things that are static
    @title = message.Messages.select {|m| m.name == 'title' }.first.Value
    if !message.Author
      @sender = DO_NOT_REPLY
    else
      @sender = message.Author.Contacts.select {|c| c.device_type == 'E-mail'}.first.Value
    end
    
    # for now, deliver IVR per recipient
    provider = message.Behavior.Delivery.Providers.select{|p| p.device == 'E-mail' && p.name == 'talho'}.first
    ivr_name = provider.ivr
    @ivr = message.IVRTree.select{|ivr| ivr.name == ivr_name}.first
    rh = {}
    message.Recipients.each do |recipient|
      messages = recipient.Devices.select{|d| d.device_type == 'E-mail'}.first.Messages
      if messages.count == 0                                      # if the recipient has no custom messages, store in the empty object hash
        rh[{}] = [] if rh[{}].nil?
        rh[{}] << recipient
      elsif messages.select{|m| !m.Value.blank?}.count > 0        # if the recipient has a custom message with a specific value, add that to a nil hash since we have to run all these guys separately.
        rh[nil] = [] if rh[nil].nil?
        rh[nil] << recipient
      else                                                        # if the recipient has a custom message but no specific values, then we add them to the hash based on what will become the message hash.
        m_ref_h = {}
        messages.each {|m| m_ref_h[m.name] = {:ref => m.ref} }    
        rh[m_ref_h] = [] if rh[m_ref_h].nil?
        rh[m_ref_h] << recipient
      end
    end
    
    rh.each do |k, v|
      if k.nil?                              # These are recipients with custom messages with specific values. Have to do these individually
        v.each {|r| do_delivery(r)}
      else                                   # These are recipients with either standard messages or the same reference messages. We already have the message hash build, so send it on to mass delivery
        do_mass_delivery(v, k)
      end
    end
  end
  
  private
  
  def do_delivery(recipient)
    device = recipient.Devices.select{|d| d.device_type == 'E-mail'}.first
    message_hash = {}
    device.Messages.each do |msg|
      message_hash[msg.name] = {:ref => msg.ref, :value => msg.Value}
    end
    txt = build_ivr(message_hash)
    GenericMailer.gen_mail({:recipients => device.URN, :from => @sender, :subject => @title, :body => txt}).deliver
  end
  
  def do_mass_delivery(recipients, message_hash)
    txt = build_ivr(message_hash)
    recip_emails = recipients.map { |r| r.Devices.select{|d| d.device_type == 'E-mail'}.first.URN }
    GenericMailer.gen_mail({:recipients => recip_emails, :from => @sender, :subject => @title, :body => txt}).deliver
  end
  
  def build_ivr(message_hash)
    msg = []
    if @ivr.nil?
      begin
        message_name = message.Behavior.Delivery.Providers.select{|p| p.device == 'E-mail'}.first.Messages.select{|m| m.name == "message"}.first.ref
      rescue
        message_name = 'message'
      end
      
      if message_hash[message_name]
        message_name = message_hash[message_name]
      elsif message_hash['message']
        message_name = message_hash['message']
      end
      return message.Messages.select{|m| m.name == message_name}.first.Value
    end
    
    @ivr.ContextNodes.each do |ctxt|
      case ctxt.operation
        when 'put', 'TTS'
          msg << ctxt.responses.map {|resp| get_text_response(resp, message_hash) }.join('')
        when 'prompt'
          msg << get_prompt_response(ctxt, message_hash)
      end
    end
    
    msg.join("\n\n")
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
  
  def get_prompt_response(ctxt, message_hash)
    href = get_text_response(ctxt.responses.first, message_hash) # The first response to a prompt with be the href
    
    if ctxt.ContextNodes && !ctxt.ContextNodes.blank? && !ctxt.ContextNodes.first.responses.blank?
      # The first response of the first context node under a prompt action will be the display text
      display_text = get_text_response(ctxt.ContextNodes.first.responses.first, message_hash)
    else
      display_text = href
    end
    
    "<a href=\"#{href}\">#{display_text}</a>"
  end
end 