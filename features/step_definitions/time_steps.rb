When /^(\d+) minutes? passe?s?$/ do |minutes|
  Time.class.send(:alias_method, :present_new, :new)
  class Time
    def new
      now = Time.present_new
      now + minutes.to_i.minutes
    end
  end
end

When /^Time is back to normal$/ do
  Time.class.send(:alias_method, :new, :present_new)
end

When /^(\d+) hours? passe?s?$/ do |hours|
  Time.class.send(:alias_method, :present_new, :new)
  class Time
    def new
      now = Time.present_new
      now + hours.to_i.hours
    end
  end
end

When /^(\d+) days? passe?s?$/ do |days|
  Time.class.send(:alias_method, :present_new, :new)
  class Time
    def new
      now = Time.present_new
      now + days.to_i.days
    end
  end
end