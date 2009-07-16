Then /^I should not see "(.*)" in the "(.*)" dropdown$/ do |text, label|
  field_labeled(label).element.inner_html.should_not contain(text)
end