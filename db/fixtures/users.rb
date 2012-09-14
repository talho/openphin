u = User.find_by_email("cdubose@texashan.org") || User.new(
  :first_name => 'Charles',
  :last_name => 'Dubose',
  :display_name => 'Charles Dubose',
  :email => 'cdubose@texashan.org',
  :password => 'Password1',
  :password_confirmation => 'Password1',
  :role_requests_attributes => [{:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.public.id}]
)

if u.new_record? && u.save
  u.confirm_email!
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.superadmin.id)
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.sysadmin.id)
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
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.superadmin.id)
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.sysadmin.id)
end

u = User.find_by_email("channa@texashan.org") || User.new(
  :first_name => 'Colin',
  :last_name => 'Hanna',
  :display_name => 'Colin Hanna',
  :email => 'channa@texashan.org',
  :password => 'Password1',
  :password_confirmation => 'Password1',
  :role_requests_attributes => [{:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.public.id}]
)

if u.new_record? && u.save
  u.confirm_email!
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.superadmin.id)
  u.role_memberships.create(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id, :role_id => Role.sysadmin.id)
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
  end
end