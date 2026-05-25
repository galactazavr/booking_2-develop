source 'https://rubygems.org'

ruby '3.3.5'

# Core
gem 'rails', '~> 7.1.3'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'

# Frontend
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'jbuilder'

# Storage & Images
gem 'image_processing', '~> 1.2'
gem 'active_storage_validations', '~> 0.9'

# Auth & Authorization
gem 'devise'
gem 'pundit'

# Background Jobs
gem 'sidekiq', '~> 7.0'

# Pagination
gem 'kaminari'

# Performance
gem 'bootsnap', require: false
gem 'redis', '>= 4.0.1'

# Windows compatibility
gem 'tzinfo-data', platforms: %i[ windows jruby ]

group :development, :test do
  gem 'debug', platforms: %i[ mri windows ]
  gem 'byebug'
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'web-console'
  gem 'listen', '~> 3.3'
  gem 'spring'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'database_cleaner-active_record'
  gem 'pundit-matchers', '~> 3.0'
end
