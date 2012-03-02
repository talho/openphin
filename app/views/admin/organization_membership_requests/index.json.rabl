
collection @requests
attributes :id
node(:name) {|r| r.user.display_name}
node(:organization) {|r| r.organization.name}
node(:email) {|r| r.user.email}
