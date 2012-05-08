module UserModules
  module Forum
    def forum_owner_of?(object)
      return (object.is_a?(::Forum) && object.owner_id == self.id)
    end
    
    def moderator_of?(object)
      return (object.is_a?(::Forum) && !object.moderator_audience.nil? && object.moderator_audience.has_user?(self.id))
    end         
  end
end