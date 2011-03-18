class HanAlertPresenter < CachingPresenter
  presents :han_alert, :accepts => [:action, :current_user]

  attr_reader :action

  def statistics
    self.statistics
  end
  
  def acknowledged_by_user?
    if attempt = self.alert_attempts.find_by_user_id(@current_user)
      attempt.acknowledged?
    end
  end

  def ask_for_acknowledgement?
    self.acknowledge? && !self.new_record? && !acknowledged_by_user?
  end

end