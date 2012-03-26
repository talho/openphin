require 'action_controller/deprecated/dispatcher'

module DelayedJobOverride
  module Object
    def send_later(*args)
      self.send(*args)
    end
  end

  ActionController::Dispatcher.to_prepare do
    if Rails.env == "development" && ENV["DELAYED_JOB_OVERRIDE"]
      ::Object.send(:include, DelayedJobOverride::Object)
    end
  end
end

