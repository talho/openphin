class AlertPresenter < CachingPresenter
  presents :alert, :accepts => [:action]
  attr_reader :action
end