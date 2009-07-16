# System-roles
Role.seed_many(:name, [
  {:name => Role::ADMIN, :approval_required => false, :user_role => false}
])