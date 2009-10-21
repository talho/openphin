# Install hook code here

Role.create(:name => "Rollcall", :user_role => false) unless Role.find_by_name("Rollcall").exists?