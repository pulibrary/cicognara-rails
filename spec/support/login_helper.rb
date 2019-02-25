module LoginHelper
  def stub_admin_user
    user = User.create!(email: 'admin@admin.com', role: 'admin')
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    user
  end

  def stub_public_user
    user = User.create!(email: 'user@user.com')
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    user
  end
end

RSpec.configure do |config|
  config.include LoginHelper
end
