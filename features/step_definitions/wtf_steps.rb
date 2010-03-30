When "I see WTF is going on" do
  save_and_open_page
end

When "I want to debug" do
  debugger
  true # needed for the debugger
end

When "I want to break" do
  $break = true
end