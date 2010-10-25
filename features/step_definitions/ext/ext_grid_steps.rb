
When /^I click ([a-zA-Z0-9\-_]*) on the "([^\"]*)" grid row(?: within "([^"]*)")?$/ do |selector, content, within_selector|
  # we want to find the row with the content, and get the div that's a few levels up
  with_scope(within_selector) do
    row = page.find(:xpath, "//div[contains(concat(' ', @class, ' '), 'x-grid3-row') and .//text() = '#{content}']")

    if row.nil?
      sleep(1)
      row = page.find(:xpath, "//div[contains(concat(' ', @class, ' '), 'x-grid3-row') and .//text() = '#{content}']")
    end

    row.find(:xpath, ".//*[contains(concat(' ', @class, ' '), '#{selector}')]").click
  end
end

When /^I select the "([^"]*)" grid row(?: within "([^"]*)")?$/ do |content, within_selector|
  # we want to find the row with the content, and get the div that's a few levels up
  with_scope(within_selector) do
    row = page.find(:xpath, "//div[contains(concat(' ', @class, ' '), 'x-grid3-row') and .//text() = '#{content}']")

    if row.nil?
      sleep(1)
      row = page.find(:xpath, "//div[contains(concat(' ', @class, ' '), 'x-grid3-row') and .//text() = '#{content}']")
    end

    row.click
  end
end

Then /^I should (not )?see "([^\"]*)" in grid row ([0-9]*)(?: within "([^"]*)")?$/ do |not_exists, content, num, within_selector|
  #we're expecting num to be 1-indexed in tests.
  with_scope(within_selector) do
    #first make sure the row is there at all
    if not_exists.nil?
      row = page.find(:xpath, "//div[contains(concat(' ', @class, ' '), 'x-grid3-row') and .//text() = '#{content}']")

      if row.nil?
        sleep(1)
        row = page.find(:xpath, "//div[contains(concat(' ', @class, ' '), 'x-grid3-row') and .//text() = '#{content}']")
      end

      if row.nil?
        raise "Could not find the specified row in the grid."
      end
    end

    #now, get all
    grid = page.find(:xpath, "//div[contains(concat(' ', @class, ' '), ' x-grid3 ') and .//div[contains(@class, 'x-grid3-row') and .//text() = '#{content}']]")
    rows = grid.all(:xpath, ".//div[contains(concat(' ', @class, ' '), ' x-grid3-row ')]")

    if not_exists.nil?
      rows[num.to_i - 1].node.text.should =~ /#{content}/ #convert 1-indexed to 0-indexed and test
    else
      rows[num.to_i - 1].node.text.should_not =~ /#{content}/ #convert 1-indexed to 0-indexed and test
    end
  end
end

When /^the "([^\"]*)" grid row should (not )?have the ([a-zA-Z0-9\-_]*) icon$/ do |content, not_exists, icon_name|
  # we want to find the row with the content, and get the div that's a few levels up
  begin
    row = page.find(:xpath, "//div[contains(concat(' ', @class, ' '), 'x-grid3-row') and .//text() = '#{content}']")

    if row.nil?
      sleep(1)
      row = page.find(:xpath, "//div[contains(concat(' ', @class, ' '), 'x-grid3-row') and .//text() = '#{content}']")
    end

    if not_exists.nil?
      row.find(:xpath, ".//*[contains(concat(' ', @class, ' '), ' #{icon_name} ')]").should_not be_nil
    else
      row.find(:xpath, ".//*[contains(concat(' ', @class, ' '), ' #{icon_name} ')]").should be_nil
    end
  rescue Selenium::WebDriver::Error::ObsoleteElementError
    When %Q{the "#{content}" grid row should have the #{icon_name} icon}
  end
end