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

    # Sidekiq uses eager loading, but directories not in the standard Rails
    # directories must be added to the eager load paths:
    # https://github.com/mperham/sidekiq/wiki/FAQ#why-doesnt-sidekiq-autoload-my-rails-application-code
    # Also, there is no need to add `lib` to autoload_paths since autoloading is
    # configured to check for eager loaded paths:
    # https://github.com/rails/rails/blob/v4.2.6/railties/lib/rails/engine.rb#L687
    # This is a nice reference article on autoloading/eager loading:
    # http://blog.arkency.com/2014/11/dont-forget-about-eager-load-when-extending-autoload
    config.eager_load_paths.push(*%W[#{config.root}/lib
      #{config.root}/app/models/badges
      #{config.root}/app/models/hooks
      #{config.root}/app/models/members
      #{config.root}/app/models/project_services
      #{config.root}/app/graphql/resolvers/concerns
      #{config.root}/app/graphql/mutations/concerns])

    config.generators.templates.push("#{config.root}/generator_templates")

    if Gitlab.ee?
      ee_paths = config.eager_load_paths.each_with_object([]) do |path, memo|
        ee_path = config.root.join('ee', Pathname.new(path).relative_path_from(config.root))
        memo << ee_path.to_s
      end

      # Eager load should load CE first
      config.eager_load_paths.push(*ee_paths)
      config.helpers_paths.push "#{config.root}/ee/app/helpers"

      # Other than Ruby modules we load EE first
      config.paths['lib/tasks'].unshift "#{config.root}/ee/lib/tasks"
      config.paths['app/views'].unshift "#{config.root}/ee/app/views"
    end

    # Rake tasks ignore the eager loading settings, so we need to set the
    # autoload paths explicitly
    config.autoload_paths = config.eager_load_paths.dup

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
