if Rails.env.test?
  require 'simplecov'
  if ENV['CIRCLE_ARTIFACTS']
    SimpleCov.coverage_dir(File.join(ENV['CIRCLE_ARTIFACTS'], 'coverage'))
  end
  SimpleCov.start('rails') do
    add_filter '/spec'
  end
end
