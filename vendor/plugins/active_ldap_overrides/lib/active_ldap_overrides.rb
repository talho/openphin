# ActiveLdapOverrides

module ActiveLdap
  module Associations
    module ClassMethods
      def belongs_to_with_no_foreign_key(association_id, options={})
        if options[:primary_key]
          options[:foreign_key => options[:primary_key].split(",").drop(1).join(",")]
        end
        belongs_to_without_no_foreign_key(association_id, options)

      end
      alias_method_chain(:belongs_to, :no_foreign_key)
    end
  end
end
