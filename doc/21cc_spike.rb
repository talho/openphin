require 'rubygems'
require File.dirname(__FILE__) + '/../config/boot'

require 'ruby-debug'
require 'builder'
require 'httparty'
require 'base64'

# TO RUN THIS: irb -r path/to/file
# IT WILL LOAD RAILS FOR YOU

unless File.exists?("a.wav")
  puts
  puts "THERE IS NO a.wav FILE FOUND. THIS WILL BE NEEDED TO DO VOICE CALLS"
  puts "BUT YOU SHOULD BE GOOD FOR EVERYTHING ELSE"
  puts
end

module Builder
  class XmlMarkup
    def inspect
      @target
    end
  end
end

class Tfcc
  include HTTParty
  basic_auth "tdh_talho", "qtvu71uu" 
  base_uri "https://ucstest.tfcci.com/ucsxml"
  
  def list_programs
    body = ""
    xml = ::Builder::XmlMarkup.new :target => body, :indent => 2
    xml.instruct!
    xml.ucsxml :version=>"1.1", :xmlns=>"http://ucs.tfcci.com" do |ucsxml|
      ucsxml.request :method => "query" do |request|
        request.cli_id "63"
        request.usr_id "1089"
        request.cust_ref "0"
        request.program do |program|
          # program.id "2629128"
          program.channel "outdial" # outdial
          # program.status ""
        end
      end
    end

    puts "sending"
    puts "-"*20
    puts body
    puts
    response = self.class.post('/request.cgi', :body => body,
      :headers => { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml/html'}
    )
  end
  
  def create_program
    body = ""
    xml = ::Builder::XmlMarkup.new :target => body, :indent => 2
    xml.instruct!
    xml.ucsxml :version=>"1.1", :xmlns=>"http://ucs.tfcci.com" do |ucsxml|
      ucsxml.request :method => "create" do |request|
        request.cli_id "63"
        request.usr_id "1089"
        request.cust_ref "0"
        request.program :name => "Test message", :desc => "Test message description", 
          :channel => "outdial", :template => "0" do |program|
          program.content do |content|
            content.slot :id => "1", :type => "TTS" "This is a test message."
          end
        end
      end
    end

    response = self.class.post('/request.cgi', :body => body,
      :headers => { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml/html'}
    )
    puts response
  end

  def play_music
    body = ""
    xml = ::Builder::XmlMarkup.new :target => body, :indent => 2
    xml.instruct!
    xml.ucsxml :version=>"1.1", :xmlns=>"http://ucs.tfcci.com" do |ucsxml|
      ucsxml.request :method => "create" do |request|
        request.cli_id "63"
        request.usr_id "1089"
        request.cust_ref "0"
        request.activation :start => Time.now.strftime("%Y%m%d%H%M%S"), :stop => (Time.now + 30.minutes).strftime("%Y%m%d%H%M%S") do |activation|
          activation.campaign do |campaign|
            campaign.program :name => "Test message", :desc => "Test message description", 
              :channel => "outdial", :template => "0" do |program|
              program.addresses :address => "c0", :retry_num => "0", :retry_wait => "0"
              program.content do |content|
                content.slot Base64.encode64s(IO.read("a.wav")), :id => "1", :type => "VOICE", :encoding => "base64", :format => "wav"
              end
            end

            campaign.audience do |audience|
              audience.contact do |contact|
                contact.c0  "5125657931", :type => "phone"
                contact.c1  "Ethan", :type => "string"
              end
            end
          end
        end
      end
    end

    response = self.class.post('/request.cgi', :body => body,
      :headers => { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml/html'}
    )
    puts response
  end

  def create_program_and_activation
    body = ""
    xml = ::Builder::XmlMarkup.new :target => body, :indent => 2
    xml.instruct!
    xml.ucsxml :version=>"1.1", :xmlns=>"http://ucs.tfcci.com" do |ucsxml|
      ucsxml.request :method => "create" do |request|
        request.cli_id "63"
        request.usr_id "1089"
        request.activation :start => Time.now.strftime("%Y%m%d%H%M%S"), :stop => (Time.now + 30.minutes).strftime("%Y%m%d%H%M%S") do |activation|
          activation.campaign do |campaign|
            campaign.program :name => "Test message", :desc => "Test message description 9999", :channel => "outdial", :template => "0" do |program|
              program.addresses :address => "c0", :retry_num => "0", :retry_wait => "0"
              program.content do |content|
                msg = %|Hello again <data source="c1" name="name"> This is a test message. Six.|
                content.slot msg, :id => "1", :type => "TTS" 
              end
            end
            campaign.audience do |audience|
              audience.contact do |contact|
                contact.c0  "5125657931", :type => "phone"
                contact.c1  "Ethan", :type => "string"
              end
              audience.contact do |contact|
                contact.c0 "6163186739", :type => "phone" 
                contact.c1  "Zach", :type => "string"
              end
            end
          end
        end
      end
    end

    puts body
    puts
    response = self.class.post('/request.cgi', :body => body,
      :headers => { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml/html'}
    )
    puts response
  end
  
  def register_music
    body = ""
    xml = ::Builder::XmlMarkup.new :target => body, :indent => 2
    xml.instruct!
    xml.ucsxml :version=>"1.1", :xmlns=>"http://ucs.tfcci.com" do |ucsxml|
      ucsxml.request :method => "create" do |request|
        request.cli_id "63"
        request.usr_id "1089"
        request.cust_ref "0"
        request.program :name => "Voice test message", :desc => "Voice ZZZZZZZZZ", 
          :channel => "outdial", :template => "0" do |program|
          program.addresses :address => "c0", :retry_num => "0", :retry_wait => "0"
          program.content do |content|
            content.slot Base64.encode64s(IO.read("a.wav")), :id => "1", :type => "VOICE", :encoding => "base64", :format => "wav"
          end
        end
      end
    end
    
    puts body
    response = self.class.post('/request.cgi', :body => body,
      :headers => { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml/html'}
    )
    puts response
  end

  # When you use this, you have to have a program id. To get this you have to create
  # a program (see #register_program). If you look at the output of the response there is a
  # 'id' that returns a number. This is the program id.
  def activate_music
    body = ""
    xml = ::Builder::XmlMarkup.new :target => body, :indent => 2
    xml.instruct!
    xml.ucsxml :version=>"1.1", :xmlns=>"http://ucs.tfcci.com" do |ucsxml|
      ucsxml.request :method => "create" do |request|
        request.cli_id "63"
        request.usr_id "1089"
        request.activation :start => Time.now.strftime("%Y%m%d%H%M%S"), :stop => (Time.now + 30.minutes).strftime("%Y%m%d%H%M%S") do |activation|
          activation.campaign do |campaign|
            campaign.program :id => "2735041", :channel => "outdial" do |program|
              program.addresses :address => "c0", :retry_num => "0", :retry_wait => "0"
            end
            campaign.audience do |audience|
              audience.contact do |contact|
                contact.c0  "5125657931", :type => "phone"
                contact.c1  "Ethan", :type => "string"
              end
              audience.contact do |contact|
                contact.c0 "6163186739", :type => "phone" 
                contact.c1  "Zach", :type => "string"
              end
            end
          end
        end
      end
    end

    puts body
    puts
    response = self.class.post('/request.cgi', :body => body,
      :headers => { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml/html'}
    )
    puts response
  end

  
end
