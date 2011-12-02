module Report

  module Select

    module Base
      extend ActiveSupport::Memoizable

      # included in recipe.rb for recipes_controller#index
      def selectable
        marker = UnSelectable
        send(:subclasses).select{|s| !s.ancestors.include?(marker)}
      end
      memoize :selectable

      def unselectable
        marker = UnSelectable
        send(:subclasses).select{|s| s.ancestors.include?(marker)}
      end
      memoize :unselectable

      def all
        send(:subclasses)
      end
      memoize :all

      def is_selectable?
        marker = UnSelectable
        ancestors.include?(marker)
      end

    end
  end

end

