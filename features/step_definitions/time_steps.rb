When /^(\d+) minutes? passe?s?$/ do |minutes|
  now = Time.now
  Time.stub!(:now).and_return(now + minutes.to_i.minutes)
end

When /^(\d+) hours? passe?s?$/ do |hours|
  now = Time.now
  Time.stub!(:now).and_return(now + hours.to_i.hours)
end

When /^(\d+) days? passe?s?$/ do |days|
  now = Time.now
  Time.stub!(:now).and_return(now + days.to_i.days)
end