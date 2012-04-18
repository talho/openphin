module DelayedJobOverride
  module Object
    def send_later(*args)
      self.send(*args)
    end
  end
end

::Object.send(:include, DelayedJobOverride::Object) if Rails.env == "development" && ENV["DELAYED_JOB_OVERRIDE"]