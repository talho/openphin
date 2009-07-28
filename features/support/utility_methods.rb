module FeatureHelpers
  module UtilityMethods
    def true_or_false(value)
      return true if value =~ /yes/i
      false
    end
  end
end

World(FeatureHelpers::UtilityMethods)