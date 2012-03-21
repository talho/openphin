When /^I click ([a-zA-Z0-9\-_]*) on the "([^\"]*)" grid row(?: within "([^"]*)")?$/ do |selector, content, within_selector|
  # we want to find the row with the content, and get the div that's a few levels up
  with_scope(within_selector) do
    waiter do
      page.find(".x-grid3-row", :text => content.strip).find(".#{selector.strip}").click
    end
  end
end

When /^I select the "([^"]*)" grid header(?: within "([^"]*)")?$/ do |content, within_selector|
  # we want to find the row with the content, and get the div that's a few levels up
  with_scope(within_selector) do
    waiter do
      page.find("td.x-grid3-hd", :text => content).click
    end
  end
end

When /^I select the "([^"]*)" grid row(?: within "([^"]*)")?$/ do |content, within_selector|
  # we want to find the row with the content, and get the div that's a few levels up
  with_scope(within_selector) do
    waiter do
      page.find(".x-grid3-row", :text => content).click
    end
  end
end

When /^I explicitly select the "([^"]*)" grid row(?: within "([^"]*)")?$/ do |content, within_selector|
  # similar to 'I select the "derp" grid row' except this expects an exact string match
  with_scope(within_selector) do
    waiter do
      page.find(".x-grid3-row", :text => /^#{content}$/).click
    end
  end
end

When /^I select the "([^"]*)" grid cell(?: within "([^"]*)")?$/ do |content, within_selector|
  # we want to find the row with the content, and get the div that's a few levels up
  with_scope(within_selector) do
    waiter do
      page.find(".x-grid3-cell", :text => content).click
    end
  end
end

Then /^I should (not )?see "([^\"]*)" in grid row ([0-9]*)(?: column ([a-zA-Z0-9_]*))?(?: within "([^"]*)")?$/ do |not_exists, content, rownum, colnum, within_selector|
  column = if(colnum)
    colnum = colnum.to_i - 1 if colnum =~ /^[0-9]+$/
    " and contains(@class, 'x-grid3-col-#{colnum}')"
  else
    ""
  end

  #we're expecting num to be 1-indexed in tests.
  with_scope(within_selector) do
    waiter do
      @grid = page.find(:xpath, ".//div[contains(concat(' ', @class, ' '), ' x-grid3 ') and .//div[contains(@class, 'x-grid3-row') and .//*[contains(text(), '#{content}')#{column}] ]]")
    end

    @grid.should_not be_nil unless not_exists

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

Then /^I should see (\d+) rows? in grid "([^\"]*)"$/ do |row_count, grid_class|
  waiter do
    @grid = page.find(:xpath, ".//div[contains(@class, '#{grid_class}')] ")
  end
  @grid.all(:xpath, ".//div[contains(concat(' ', @class, ' '), ' x-grid3-row ')]").count.to_s.should == row_count
end

Then /^the grid "([^"]*)" should( not)? contain:$/ do |grid_class, not_exists, table|
  waiter do
    @grid = page.find(grid_class)
  end

  @grid.should_not be_nil

  grid_rows = @grid.all('.x-grid3-row').inject([]){|a,grid_row| a.push(grid_row.text.split(/\n/))}
  results = table.rows.collect{|table_row|
    grid_rows.find{|grid_row|
      !table_row.reject{|r| r.blank?}.collect{|item|
        grid_row.include?(item)
      }.include?(false)
    }
  }
  if not_exists.nil?
    results.include?(nil).should be_false
  else
    results.compact.empty?.should be_true
  end
end

Then /^I should (not )?see "([^"]*)" in column "([^"]*)" within "([^"]*)"$/ do |not_exists, text, column, grid_class|
  waiter do
    @grid = page.find(:xpath, ".//div[contains(@class, '#{grid_class}')] ")
  end
  cell_values = []
  if @grid
    headers = @grid.all(:xpath, ".//div[contains(concat(' ', @class, ' '), ' x-grid3-header ')]")
    rows = @grid.all(:xpath, ".//div[contains(concat(' ', @class, ' '), ' x-grid3-row ')]")
    rows.each do |r|
      cell_values.push(r.text.split("\n")[headers.first.text.split("\n").index(column)] )
    end
  end
  matched_cells = cell_values.collect{|cv| cv =~ /#{text}/ }.compact
  not_exists.nil? ? (matched_cells.blank?.should be_false) : (matched_cells.blank?.should be_true)
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
  if not_exists
    page.should have_no_css(".x-grid3-row-selected", :text => content)
  else
    page.should have_css(".x-grid3-row-selected", :text => content)
  end
end

def row_button_exists?(icon_name, content)
  using_wait_time(0.1) do
    page.find(".x-grid3-row", :text => content).has_css?(".#{icon_name}")
  end
end

Then /^I should see the grid items in this order "([^\"]*)"$/ do |orders|
  orders = orders.split
  orders.each do |order|
    cmp = order.split(">")
    Then %Q{I should see "#{cmp[0]}" in grid row #{cmp[1]}}
  end
end