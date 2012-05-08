module UserModules
  module Forum
    def forum_owner_of?(object)
      return object.owner_id == self.id
    end
    
    def moderator_of(object)
      if object.class == Forum && object.moderator_audience && object.moderator_audience.has_user?(self.id)
        return true
      end
      return false
    end
  end
end