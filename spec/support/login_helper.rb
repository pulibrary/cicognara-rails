module LoginHelper
  def stub_admin_user
    user = double('user')
    allow(user).to receive(:admin?).and_return(true)
    allow(user).to receive(:bookmarks).and_return([])
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end
end

RSpec.configure do |config|
  config.include LoginHelper
end
