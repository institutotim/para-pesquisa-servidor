ruby '2.1.7'
source 'http://rubygems.org'

gem 'sentry-raven'
gem 'rails', '4.0.0'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'rocket_pants', '~> 1.0'
gem 'will_paginate', '~> 3.0.4'
gem 'cancan'
gem 'active_model_serializers'
gem 'execjs'
gem 'rack-cors', require: 'rack/cors'
gem 'pg'
gem 'carrierwave'
gem 'deep_cloneable', '~> 1.5.5'
gem 'fog', '~> 1.3.1'
gem 'redis-rails'
gem 'racksh'
gem 'foreman'

# Dependencias apenas do projeto Agentes da Transformação
gem 'SyslogLogger', '~> 2.0'
gem 'newrelic_rpm'
gem 'rocket_pants-rpm', git: "https://github.com/warmwind/rocket_pants-rpm.git"
gem 'active_record_query_trace'

group :development, :test do
  gem 'test-unit'
  gem 'sqlite3'
  gem 'rspec-rails', '~> 2.0'
  gem 'fabrication'
  gem 'shoulda-matchers'
  gem 'mocha', require: false
  gem 'database_cleaner'
  gem 'pry'
  gem 'pry-nav'
end

group :production do
  gem 'rails_12factor'
  gem 'unicorn'
  gem 'jquery-rails'
  gem 'turbolinks'
  gem 'uglifier'
  gem 'sass-rails'
end
