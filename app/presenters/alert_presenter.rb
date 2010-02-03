class AlertPresenter < CachingPresenter
  presents :alert, :accepts => [:action, :current_user]

  attr_reader :action

  def statistics
    @alert.statistics
  end
  
  def acknowledged_by_user?
    if attempt = @alert.alert_attempts.find_by_user_id(@current_user)
      attempt.acknowledged?
    end
  end

  def ask_for_acknowledgement?
    @alert.acknowledge? && !@alert.new_record? && !acknowledged_by_user?
  end
end