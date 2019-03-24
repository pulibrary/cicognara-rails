class User < ActiveRecord::Base
  after_initialize :set_default_role
  validates :role, inclusion: { in: %w(admin curator user), message: '%{value} is not a valid role' }
  validates :email, presence: true

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
  devise :omniauthable, :registerable, omniauth_providers: [:google_oauth2]

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.find_by(email: data['email'])
    user = User.create(email: data['email']) unless user
    user
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end
end
