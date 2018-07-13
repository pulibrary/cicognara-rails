class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.admin?
      admin_permissions
    elsif user.curator?
      curator_permissions
    else
      public_permissions
    end
  end

  def admin_permissions
    can :manage, :all
  end

  def curator_permissions
    can :read, Book
    can :create, Comment
    can [:edit, :update, :delete], Comment do |obj|
      obj.user_id == current_user.id
    end
    can :manage, Version
  end

  def public_permissions
    can :read, Comment
  end
end
