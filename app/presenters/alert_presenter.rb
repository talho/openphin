class AlertPresenter < CachingPresenter
  presents :alert, :accepts => [:action]
  
  def is_cancelling?
    @action == "cancel"
  end
  
  def is_updating?
    @action == "update"
  end
end