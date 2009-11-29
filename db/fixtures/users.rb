u = User.find_or_create_by_email(:email => "keith@example.com") { |m|
  m.first_name = 'Keith'
  m.last_name = 'Gaddis'
  m.display_name = 'Keith Gaddis'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.admin.id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id,
                                                                             :user_id => u.id)
u.role_memberships << r

u = User.find_or_create_by_email(:email => "bob@example.com") { |m|
  m.first_name = 'Bob'
  m.last_name = 'Dole'
  m.display_name = 'Bob Dole'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Potter').id,
                                                                             :role_id => Role.org_admin.id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Potter').id,
                                                                             :role_id => Role.admin.id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Potter').id,
                                                                             :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id,
                                                                             :user_id => u.id)
u.role_memberships << r

u = User.find_or_create_by_email(:email => "ethan@example.com") { |m|
  m.first_name = 'Ethan'
  m.last_name = 'Waldo'
  m.display_name = 'Ethan Waldo'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id,
                                                                             :user_id => u.id)
u.role_memberships << r

u = User.find_or_create_by_email(:email => "jason@example.com") { |m|
  m.first_name = 'Jason'
  m.last_name = 'Phipps'
  m.display_name = 'Jason Phipps'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Potter').id,
                                                                             :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id,
                                                                             :user_id => u.id)
u.role_memberships << r

u = User.find_or_create_by_email(:email => "brandon@example.com") { |m|
  m.first_name = 'Brandon'
  m.last_name = 'Keepers'
  m.display_name = 'Brandon Keepers'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Potter').id,
                                                                             :role_id => Role.find_by_name('Health Officer').id,
                                                                             :user_id => u.id)
u.role_memberships << r

u = User.find_or_create_by_email(:email => "daniel@example.com") { |m|
  m.first_name = 'Daniel'
  m.last_name = 'Morrison'
  m.display_name = 'Daniel Morrison'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Wise').id,
                                                                             :role_id => Role.find_by_name('Health Officer').id,
                                                                             :user_id => u.id)
u.role_memberships << r

u = User.find_or_create_by_email(:email => "zach@example.com") { |m|
  m.first_name = 'Zach'
  m.last_name = 'Dennis'
  m.display_name = 'Zach Dennis'
  m.email_confirmed = false
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

u = User.find_or_create_by_email(:email => "jason@texashan.org") { |m|
  m.first_name = 'Jason'
  m.last_name = 'Phipps'
  m.display_name = 'Jason Phipps'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.admin.id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id,
                                                                             :user_id => u.id)
u.role_memberships << r

u = User.find_or_create_by_email(:email => "jphipps@texashan.org") { |m|
  m.first_name = 'Jason'
  m.last_name = 'Phipps'
  m.display_name = 'Jason Phipps'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Wise').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Wise').id,
                                                                              :role_id => Role.admin.id,
                                                                              :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Wise').id,
                                                                             :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id,
                                                                             :user_id => u.id)
u.role_memberships << r

u = User.find_or_create_by_email(:email => "jphipps@talho.org") { |m|
  m.first_name = 'Jason'
  m.last_name = 'Phipps'
  m.display_name = 'Jason Phipps'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Wise').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

u = User.find_or_create_by_email(:email => "jason.phipps@earthlink.net") { |m|
  m.first_name = 'Jason'
  m.last_name = 'Phipps'
  m.display_name = 'Jason Phipps'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

u = User.find_or_create_by_email(:email => "ewaldo@talho.org") { |m|
  m.first_name = 'Ethan'
  m.last_name = 'Weirdo'
  m.display_name = 'Ethan Weirdo'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Armstrong').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Armstrong').id,
                                                                             :role_id => Role.admin.id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Armstrong').id,
                                                                             :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id,
                                                                             :user_id => u.id)
<<<<<<< HEAD
u.role_memberships << r

u = User.find_or_create_by_email(:email => "rboldway@talho.org") { |m|
  m.first_name = 'Richard'
  m.last_name = 'Boldway'
  m.display_name = 'Richard Boldway'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Bell').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Bell').id,
                                                                             :role_id => Role.admin.id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Bell').id,
                                                                             :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id,
                                                                             :user_id => u.id)
=======
>>>>>>> f0a76abb3114bb683db526cfc14e993a9b3207ab
u.role_memberships << r

u = User.find_or_create_by_email(:email => "rboldway@talho.org") { |m|
  m.first_name = 'Richard'
  m.last_name = 'Boldway'
  m.display_name = 'Richard Boldway'
<<<<<<< HEAD
  m.email = 'richard@boldway.org'
=======
>>>>>>> f0a76abb3114bb683db526cfc14e993a9b3207ab
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Bell').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Bell').id,
                                                                             :role_id => Role.admin.id,
                                                                             :user_id => u.id)
u.role_memberships << r


r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Bell').id,
                                                                             :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id,
                                                                             :user_id => u.id)
u.role_memberships << r

u = User.find_or_create_by_email(:email => "pradeep.vittal@dshs.state.tx.us") { |m|
  m.first_name = 'Pradeep'
  m.last_name = 'Vittal'
  m.display_name = 'Pradeep Vittal'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
}

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.find_by_name('Public').id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.admin.id,
                                                                             :user_id => u.id)
u.role_memberships << r

r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Bell').id,
                                                                             :role_id => Role.find_by_name('Health Alert and Communications Coordinator').id,
                                                                             :user_id => u.id)
u.role_memberships << r
r = RoleMembership.find_or_create_by_jurisdiction_id_and_role_id_and_user_id(:jurisdiction_id => Jurisdiction.find_by_name('Texas').id,
                                                                             :role_id => Role.superadmin.id,
                                                                             :user_id => u.id)
u.role_memberships << r
