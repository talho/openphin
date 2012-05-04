FactoryGirl.factories.each do |name, factory|
  Given /^an? #{name} exists with an? (.*) of "([^"]*)"$/ do |attr, value|
    FactoryGirl.create(name, attr.gsub(' ', '_') => value)
  end
end
