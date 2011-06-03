u = User.find_by_email("keith@example.com") || User.new(
  :first_name => 'Keith',
  :last_name => 'Gaddis',
  :display_name => 'Keith Gaddis',
  :email => 'keith@example.com',
  :password => 'Password1',
  :password_confirmation => 'Password1',
  :role_requests_attributes => [{:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.public.id}]
)

if u.new_record? && u.save
  u.confirm_email!
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.admin.id)
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id)
end

u = User.find_by_email("bob@example.com") || User.new(
  :first_name => 'Bob',
  :last_name => 'Dole',
  :display_name => 'Bob Dole',
  :email => 'bob@example.com',
  :password => 'Password1',
  :password_confirmation => 'Password1',
  :role_requests_attributes => [{:jurisdiction_id => Jurisdiction.find_by_name('Potter').id, :role_id => Role.public.id}]
)

if u.new_record? && u.save
  u.confirm_email!
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Potter').id,:role_id => Role.org_admin.id)
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Potter').id, :role_id => Role.admin.id)
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Potter').id, :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id)
end

u = User.find_by_email("ethan@example.com") || User.new(
  :first_name => 'Ethan',
  :last_name => 'Waldo',
  :display_name => 'Ethan Waldo',
  :email => 'ethan@example.com',
  :password => 'Password1',
  :password_confirmation => 'Password1',
  :role_requests_attributes => [{:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.public.id}]
)

if u.new_record? && u.save
  u.confirm_email!
  u.confirm_email!
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id)
end

u = User.find_by_email("brandon@example.com") || User.new(
  :first_name => 'Brandon',
  :last_name => 'Keepers',
  :display_name => 'Brandon Keepers',
  :email => 'brandon@example.com',
  :password => 'Password1',
  :password_confirmation => 'Password1',
  :role_requests_attributes => [{:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.public.id}]
)

if u.new_record? && u.save
  u.confirm_email!
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Potter').id, :role_id => Role.find_by_name('Health Officer').id)
end

u = User.find_by_email("daniel@example.com") || User.new(
  :first_name => 'Daniel',
  :last_name => 'Morrison',
  :display_name => 'Daniel Morrison',
  :email => 'daniel@example.com',
  :password => 'Password1',
  :password_confirmation => 'Password1',
  :role_requests_attributes => [{:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.public.id}]
)

if u.new_record? && u.save
  u.confirm_email!
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Wise').id, :role_id => Role.find_by_name('Health Officer').id)
end

u = User.find_by_email("zach@example.com") || User.create(
  :first_name => 'Zach',
  :last_name => 'Dennis',
  :display_name => 'Zach Dennis',
  :email => 'zach@example.com',
  :password => 'Password1',
  :password_confirmation => 'Password1',
  :role_requests_attributes => [{:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.public.id}]
)

u = User.find_by_email("ewaldo@talho.org") || User.new(
  :first_name => 'Ethan',
  :last_name => 'Weirdo',
  :display_name => 'Ethan Weirdo',
  :email => 'ewaldo@talho.org',
  :password => 'Password1',
  :password_confirmation => 'Password1',
  :role_requests_attributes => [{:jurisdiction_id => Jurisdiction.find_by_name('Armstrong').id, :role_id => Role.public.id}]
)

if u.new_record? && u.save
  u.confirm_email!
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Armstrong').id, :role_id => Role.admin.id)
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Armstrong').id, :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id)
end

u = User.find_by_email("rboldway@talho.org") || User.new(
  :first_name => 'Richard',
  :last_name => 'Boldway',
  :display_name => 'Richard Boldway',
  :email => 'rboldway@talho.org',
  :password => 'Password1',
  :password_confirmation => 'Password1',
  :role_requests_attributes => [{:jurisdiction_id => Jurisdiction.find_by_name('Bell').id, :role_id => Role.public.id}]
)

if u.new_record? && u.save
  u.confirm_email!
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Bell').id, :role_id => Role.admin.id)
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Bell').id, :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id)
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.superadmin.id)
end

u = User.find_by_email("pradeep.vittal@dshs.state.tx.us") || User.new(
  :first_name => 'Pradeep',
  :last_name => 'Vittal',
  :display_name => 'Pradeep Vittal',
  :email => 'pradeep.vittal@dshs.state.tx.us',
  :password => 'Password1',
  :password_confirmation => 'Password1',
  :role_requests_attributes => [{:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.public.id}]
)

if u.new_record? && u.save
  u.confirm_email!
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.admin.id)
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Bell').id, :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id)
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.superadmin.id)
end

u = User.find_by_email("eddie@talho.org") || User.new(
  :first_name => 'Eduardo',
  :last_name => 'Gomez',
  :display_name => 'Eddie Gomez',
  :email => 'eddie@talho.org',
  :password => 'Password1',
  :password_confirmation => 'Password1',
  :role_requests_attributes => [{:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.public.id}]
)

if u.new_record? && u.save
  u.confirm_email!
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.admin.id)
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Starr').id, :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id)
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Harris').id, :role_id => Role.find_by_name('Rollcall').id) if Role.find_by_name('Rollcall')
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.superadmin.id)
end

unless Rails.env.strip.downcase == "production"
  u = User.find_by_email("awesome@example.com") || User.new(
    :first_name => 'Awesome',
    :last_name => 'Blossoms',
    :display_name => 'Awesome Blossoms',
    :email => 'awesome@example.com',
    :password => 'Password1',
    :password_confirmation => 'Password1',
    :role_requests_attributes => [{:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.public.id}]
  )

  if u.new_record? && u.save
    u.confirm_email!
    u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.sysadmin.id)
  end
end