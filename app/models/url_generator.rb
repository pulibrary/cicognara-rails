class UrlGenerator
  include Rails.application.routes.url_helpers

  def default_url_options
    ActionMailer::Base.default_url_options
  end
end
