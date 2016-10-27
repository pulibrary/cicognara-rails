class User < ActiveRecord::Base
  after_initialize :set_default_role
  validates :role, inclusion: { in: %w(admin curator user), message: '%{value} is not a valid role' }

  def admin?
    role == 'admin'
  end

  def curator?
    role == 'curator'
  end

  def set_default_role
    self.role ||= 'user'
  end

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end
end
