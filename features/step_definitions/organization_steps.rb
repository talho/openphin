Given "there is an unapproved $name organization" do |name|
  Factory(:organization, :name => name, :approved => false)
end