class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? :admin
      cannot :manage, :user
    else
      can :read, :all
    end
  end
end