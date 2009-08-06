# System-roles
Role.seed_many(:name, [
  {:name => Role::Defaults[:admin], :approval_required => false, :user_role => false}
])