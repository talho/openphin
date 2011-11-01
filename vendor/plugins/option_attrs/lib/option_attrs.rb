module MutuallyHuman
  module ActiveRecord
    module OptionAttrs
      def option_accessor(name, options={})
        option_reader name, options
        option_writer name, options
      end

      def option_reader(name, options)
        define_method(name) do
          reader = options[:reader] || lambda { |val| val }
          self.options ||= {}
          reader.call self.options[name.to_sym]
        end
      end

      def option_writer(name, options)
        define_method("#{name}=") do |arg| 
          writer = options[:writer] || lambda { |arg| arg }
          self.options ||= {}
          self.options[name.to_sym] = writer.call arg
        end
      end
    end
  end
end

ActiveRecord::Base.extend MutuallyHuman::ActiveRecord::OptionAttrs