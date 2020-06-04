# frozen_string_literal: true

class Feature
  InvalidFeatureFlagError = Class.new(Exception) # rubocop:disable Lint/InheritException
  SUPPORTED_FEATURE_FLAG_ADAPTERS = %w[unleash flipper]

  class << self
    delegate :all, :get, :group, :persisted_name?, :table_exists?, to: :adapter

    def adapter
      @adapter ||=
        SUPPORTED_FEATURE_FLAG_ADAPTERS.find do |type|
          adapter = get_adapter(type)
          break adapter if adapter.available?
        end
    end

    # use `default_enabled: true` to default the flag to being `enabled`
    # unless set explicitly.  The default is `disabled`
    # TODO: remove the `default_enabled:` and read it from the `defintion_yaml`
    # check: https://gitlab.com/gitlab-org/gitlab/-/issues/30228
    def enabled?(key, thing = nil, default_enabled: false)
      if check_feature_flags_definition?
        if thing && !thing.respond_to?(:flipper_id)
          raise InvalidFeatureFlagError,
            "The thing '#{thing.class.name}' for feature flag '#{key}' needs to include `FeatureGate` or implement `flipper_id`"
        end
      end

      # During setup the database does not exist yet. So we haven't stored a value
      # for the feature yet and return the default.
      return default_enabled unless Gitlab::Database.exists?

      feature = get(key)

      # If we're not default enabling the flag or the feature has been set, always evaluate.
      # `persisted?` can potentially generate DB queries and also checks for inclusion
      # in an array of feature names (177 at last count), possibly reducing performance by half.
      # So we only perform the `persisted` check if `default_enabled: true`
      !default_enabled || persisted_name?(feature.name) ? feature.enabled?(thing) : true
    end

    def disabled?(key, thing = nil, default_enabled: false)
      # we need to make different method calls to make it easy to mock / define expectations in test mode
      thing.nil? ? !enabled?(key, default_enabled: default_enabled) : !enabled?(key, thing, default_enabled: default_enabled)
    end

    def enable(key, thing = true)
      get(key).enable(thing)
    end

    def disable(key, thing = false)
      get(key).disable(thing)
    end

    def enable_group(key, group)
      get(key).enable_group(group)
    end

    def disable_group(key, group)
      get(key).disable_group(group)
    end

    def enable_percentage_of_time(key, percentage)
      get(key).enable_percentage_of_time(percentage)
    end

    def disable_percentage_of_time(key)
      get(key).disable_percentage_of_time
    end

    def enable_percentage_of_actors(key, percentage)
      get(key).enable_percentage_of_actors(percentage)
    end

    def disable_percentage_of_actors(key)
      get(key).disable_percentage_of_actors
    end

    def remove(key)
      return unless persisted_name?(key)

      get(key).remove
    end

    def reset
      Gitlab::SafeRequestStore.delete(:flipper) if Gitlab::SafeRequestStore.active?
      @flipper = nil
    end

    # This method is called from config/initializers/flipper.rb and can be used
    # to register Flipper groups.
    # See https://docs.gitlab.com/ee/development/feature_flags.html#feature-groups
    def register_feature_groups
    end

    private

    def check_feature_flags_definition?
      # We want to check feature flags usage only when
      # running in development or test environment
      Gitlab.dev_or_test_env?
    end
  end

  class Target
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def gate_specified?
      %i(user project group feature_group).any? { |key| params.key?(key) }
    end

    def targets
      [feature_group, user, project, group].compact
    end

    private

    # rubocop: disable CodeReuse/ActiveRecord
    def feature_group
      return unless params.key?(:feature_group)

      Feature.group(params[:feature_group])
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def user
      return unless params.key?(:user)

      UserFinder.new(params[:user]).find_by_username!
    end

    def project
      return unless params.key?(:project)

      Project.find_by_full_path(params[:project])
    end

    def group
      return unless params.key?(:group)

      Group.find_by_full_path(params[:group])
    end
  end
end

Feature.prepend_if_ee('EE::Feature')
