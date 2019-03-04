class ApplicationController < ActionController::Base
  include CanCan::ControllerAdditions

  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout 'application'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def new_session_path(_scope)
    new_user_session_path
  end

  def current_user
    if Rails.env.development?
      User.first
    else
      super
    end
  end
end
