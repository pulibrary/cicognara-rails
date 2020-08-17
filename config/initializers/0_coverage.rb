if Rails.env.test?
  require 'simplecov'
  SimpleCov.coverage_dir(File.join(ENV['CIRCLE_ARTIFACTS'], 'coverage')) if ENV['CIRCLE_ARTIFACTS']
  SimpleCov.start('rails') do
    add_filter '/spec'
  end
end
