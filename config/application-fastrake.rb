# Based on config/application.rb
require 'bootsnap/setup' if ENV['RAILS_ENV'] != 'production' || %w(1 yes true).include?(ENV['ENABLE_BOOTSNAP'])
require 'active_record/railtie'
require 'rails'
require 'bootsnap'

module Gitlab
  class Application < Rails::Application
    require_dependency Rails.root.join('lib/gitlab')
    require_dependency Rails.root.join('lib/gitlab/utils')
    require_dependency Rails.root.join('lib/gitlab/redis/wrapper')
    require_dependency Rails.root.join('lib/gitlab/redis/cache')
    require_dependency Rails.root.join('lib/gitlab/redis/queues')
    require_dependency Rails.root.join('lib/gitlab/redis/shared_state')
    require_dependency Rails.root.join('lib/gitlab/current_settings')

    # Use caching across all environments
    caching_config_hash = Gitlab::Redis::Cache.params
    caching_config_hash[:namespace] = Gitlab::Redis::Cache::CACHE_NAMESPACE
    caching_config_hash[:expires_in] = 2.weeks # Cache should not grow forever

    config.cache_store = :redis_store, caching_config_hash

    # This is needed for gitlab-shell
    ENV['GITLAB_PATH_OUTSIDE_HOOK'] = ENV['PATH']
    ENV['GIT_TERMINAL_PROMPT'] = '0'
  end
end
