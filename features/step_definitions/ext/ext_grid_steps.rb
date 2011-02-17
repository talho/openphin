
When /^I click ([a-zA-Z0-9\-_]*) on the "([^\"]*)" grid row(?: within "([^"]*)")?$/ do |selector, content, within_selector|
  # we want to find the row with the content, and get the div that's a few levels up
  with_scope(within_selector) do
    begin
      wait_until do
        begin
          @row = page.find(".x-grid3-row", :text => content.strip)
        rescue Capybara::ElementNotFound
        end
      end

      @row.find(".#{selector.strip}").click
    rescue Capybara::TimeoutError
    end
  end
end

When /^I select the "([^"]*)" grid header(?: within "([^"]*)")?$/ do |content, within_selector|
  # we want to find the row with the content, and get the div that's a few levels up
  with_scope(within_selector) do
    begin
      wait_until do
        begin
          @header = page.find("td.x-grid3-hd", :text => content)
        rescue Capybara::ElementNotFound
        end
      end

      @header.click
    rescue Capybara::TimeoutError
    end
  end
end

When /^I select the "([^"]*)" grid row(?: within "([^"]*)")?$/ do |content, within_selector|
  # we want to find the row with the content, and get the div that's a few levels up
  with_scope(within_selector) do
    begin
      wait_until do
        begin
          @row = page.find(".x-grid3-row", :text => content)
        rescue Capybara::ElementNotFound
        end
      end

      @row.click
    rescue Capybara::TimeoutError
    end
  end
end

When /^I select the "([^"]*)" grid cell(?: within "([^"]*)")?$/ do |content, within_selector|
  # we want to find the row with the content, and get the div that's a few levels up
  with_scope(within_selector) do
    begin
      wait_until do
        begin
          @row = page.find(".x-grid3-cell", :text => content)
        rescue Capybara::ElementNotFound
        end
      end
      @row.click unless @row.nil?
    rescue Capybara::TimeoutError
    end
  end
end

Then /^I should (not )?see "([^\"]*)" in grid row ([0-9]*)(?: column ([0-9]*))?(?: within "([^"]*)")?$/ do |not_exists, content, rownum, colnum, within_selector|
  column = colnum ? " and contains(@class, 'x-grid3-col-#{colnum.to_i - 1}')" : ""

  #we're expecting num to be 1-indexed in tests.
  with_scope(within_selector) do
    begin
      wait_until do
        begin
          @grid = page.find(:xpath, "//div[contains(concat(' ', @class, ' '), ' x-grid3 ') and .//div[contains(@class, 'x-grid3-row') and .//*[contains(text(), '#{content}')#{column}] ]]")
        rescue Capybara::ElementNotFound
        end
      end
    rescue Capybara::TimeoutError
      raise "Could not find the specified row or column in the grid." if not_exists.blank?
    end

    if @grid
      rows = @grid.all(:xpath, ".//div[contains(concat(' ', @class, ' '), ' x-grid3-row ')]")

      if not_exists
        rows[rownum.to_i - 1].nil? || rows[rownum.to_i - 1].text.should_not =~ /#{content}/ #convert 1-indexed to 0-indexed and test
      else
        rows[rownum.to_i - 1].text.should =~ /#{content}/ #convert 1-indexed to 0-indexed and test
      end
    end
  end
end

When /^the "([^\"]*)" grid row should (not )?have the ([a-zA-Z0-9\-_]*) icon$/ do |content, not_exists, icon_name|
  # we want to find the row with the content, and get the div that's a few levels up
  begin
    row_button_exists?(icon_name, content).should not_exists.nil? ? be_true : be_false
  rescue Selenium::WebDriver::Error::ObsoleteElementError
    When %Q{the "#{content}" grid row should have the #{icon_name} icon}
  end
end

When /^the "([^"]*)" grid header is sorted (ascending|descending)$/ do |header, sort|
  sortcss = sort == "ascending" ? ".sort-asc" : ".sort-desc"
  Then %Q{I should see "#{header}" within "#{sortcss}"}
end

Then /^the "([^\"]*)" grid row(?: within "([^\"]*)")? should (not )?be selected$/ do |content, within_selector, not_exists|
  with_scope(within_selector) do
    begin
      wait_until do
        begin
          page.find(".x-grid3-row-selected", :text => content)
        rescue Capybara::ElementNotFound
        end
      end
    rescue Capybara::TimeoutError
      raise "Element does not exist and it should" if not_exists.nil?
    end
  end
end

def row_button_exists?(icon_name, content)
  begin
    wait_until do
      begin
        page.find(".x-grid3-row", :text => /#{content}/).find(".#{icon_name}")
      rescue Capybara::ElementNotFound
      end
    end
  rescue Capybara::TimeoutError
    return false
  end
  true
end

Then /^I should see the grid items in this order "([^\"]*)"$/ do |orders|
  orders = orders.split
  orders.each do |order|
    cmp = order.split(">")
    Then %Q{I should see "#{cmp[0]}" in grid row #{cmp[1]}}
  end
end