# Ensures that when we pass a :message parameter to our validations, that
# message is a sentence (and not something to be prefixed by the column
# name). Rationale: ActiveSupport::Inflector is in over its head on this
# one.
#
# So instead of:
#   validates_presence_of :name, :message => 'should not be blank'
# Use:
#   validates_presence_of :name, :message => 'Name should not be blank'
#
# If, however, you just use:
#   validates_presence_of :name
# The behavior will remain unchanged.
if RAILS_GEM_VERSION =~ /^2\.3/
  ActiveRecord::Errors.class_eval do
    def full_messages
      full_messages = []
 
      @errors.each_key do |attr|
        @errors[attr].each do |msg|
          next if msg.nil?
          msg = msg.respond_to?(:message) ? msg.message : msg
          if attr == "base"
            full_messages << msg
          elsif msg =~ /^\^/
            full_messages << msg[1..-1]
          elsif msg.is_a? Proc
            full_messages << msg.call(@base)
          else
            full_messages << @base.class.human_attribute_name(attr) + " " + msg
          end
        end
      end
 
      return full_messages
    end
  end   
end