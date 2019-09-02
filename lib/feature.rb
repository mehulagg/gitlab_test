# frozen_string_literal: true

class Feature
  prepend_if_ee('EE::Feature') # rubocop: disable Cop/InjectEnterpriseEditionModule

  SUPPORTED_FEATURE_FLAG_ADAPTERS = %w[unleash flipper]

  class << self
    delegate :all, :get, :group, :persisted?, :table_exists?, to: :adapter

    def adapter
      @adapter ||=
        SUPPORTED_FEATURE_FLAG_ADAPTERS.find do |type|
          adapter = get_adapter(type)
          break adapter if adapter.available?
        end
    end

    # use `default_enabled: true` to default the flag to being `enabled`
    # unless set explicitly.  The default is `disabled`
    def enabled?(key, thing = nil, default_enabled: false)
      feature = get(key)

      # If we're not default enabling the flag or the feature has been set, always evaluate.
      # `persisted?` can potentially generate DB queries and also checks for inclusion
      # in an array of feature names (177 at last count), possibly reducing performance by half.
      # So we only perform the `persisted` check if `default_enabled: true`
      !default_enabled || persisted?(feature) ? feature.enabled?(thing) : true
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

    def remove(key)
      feature = get(key)
      return unless persisted?(feature)

      feature.remove
    end

    private
    
    def get_adapter(type)
      "FeatureFlag::Adapters::#{type.camelize}".constantize
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
