source 'https://rubygems.org'
source 'https://rails-assets.org'

gem 'rails-assets-jquery.terminal'

gem 'dotenv-rails'

gem 'pg', group: :production

gem 'cloudflare'
gem 'digitalocean'

gem 'net-ssh'
gem 'net-scp'
gem 'term-ansicolor'
gem 'websocket-rails', git: 'git://github.com/websocket-rails/websocket-rails.git', ref: '7b7bc1'

gem 'haml'
gem "erb2haml", :group => :development
gem "select2-rails"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

gem 'rails_admin'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sidekiq-unique-jobs'
gem 'sinatra', require: nil
# Use unicorn as the app server
gem 'unicorn', group: :production
gem 'devise'
gem 'devise_invitable'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
gem 'bootstrap-sass', '~> 3.1.1'
group :development, :test do
  gem 'sqlite3'
  gem 'pry-rails'
  gem 'shoulda-matchers', require: false
  gem 'factory_girl_rails'
  gem 'spring-commands-rspec'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'database_cleaner'
end

gem 'webmock', group: 'test'
gem 'guard-rspec', '~> 4.2.8', require: false
gem 'guard-bundler', require: false
group :development do
  gem 'git-deploy'
  gem 'quiet_assets'
end
