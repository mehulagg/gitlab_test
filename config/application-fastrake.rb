# Based on config/application.rb
require 'bootsnap/setup' if ENV['RAILS_ENV'] != 'production' || %w(1 yes true).include?(ENV['ENABLE_BOOTSNAP'])
require 'active_record/railtie'
require 'rails'
require 'bootsnap'

module Gitlab
  class Application < Rails::Application
  end
end
