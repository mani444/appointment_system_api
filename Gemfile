# Rails 8.0+ Modern API Gemfile
source "https://rubygems.org"

# Core Rails 8.0
gem "rails", "~> 8.0.2"

# Database
gem "pg", "~> 1.1"

# Rails 8.0 Solid Trifecta (New defaults)
gem "solid_cache"
gem "solid_queue"
gem "bootsnap", require: false

# API Essentials
gem "puma", ">= 5.0"
gem "jbuilder"
gem "rack-cors"

# Authentication & Authorization
gem "jwt"
gem "bcrypt", "~> 3.1.7"

# Background Jobs (Rails 8.0 native)
# Solid Queue is now included

# Serialization
gem "active_model_serializers"

# Environment variables
gem "dotenv-rails"

# Performance & Monitoring
gem "redis", ">= 4.0.1"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "shoulda-matchers"
end

group :development do
  gem "annotate"
  gem "bullet"
  gem "listen", "~> 3.3"
  
  # Rails 8.0 enhanced console
  gem "web-console"
end

group :test do
  gem "database_cleaner-active_record"
  gem "webmock"
  gem "vcr"
end