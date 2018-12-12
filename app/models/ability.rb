class Ability
  include CanCan::Ability
  attr_reader :current_user

  def initialize(user)
    @current_user = user || User.new # guest user (not logged in)

    if current_user.admin?
      admin_permissions
    elsif current_user.curator?
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
    can [:edit, :update, :destroy], Comment do |obj|
      obj.user_id == current_user.id
    end
    can :read, NewsItem
    can :create, NewsItem
    can [:edit, :update, :destroy], NewsItem do |obj|
      obj.user_id == current_user.id
    end
    can :manage, Version
  end

  def public_permissions
    can :read, Comment
    can :read, NewsItem
  end
end
