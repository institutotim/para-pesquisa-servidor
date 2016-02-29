class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :application_config

    return if user.nil?

    if user.role == 'agent'
      can :manage, :all

    elsif user.role == 'mod'
      can :manage, :all

    elsif user.role == 'api'
      can :manage, :all
    end
  end
end
