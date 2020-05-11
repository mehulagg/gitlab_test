# frozen_string_literal: true

class Feature
  class Definition
    include Gitlab::Utils::StrongMemoize

    PARAMS = %i[
      name
      default_enabled
      type
      introduced_by_url
      rollout_issue_url
      author
      group
    ].freeze

    attr_reader :attributes

    PARAMS.each do |param|
      define_method(param) do
        attributes[param]
      end
    end

    def initialize(attributes = {})
      @attributes = attributes.slice(*PARAMS)
    end

    def key
      name.to_sym
    end

    def valid!
      raise Feature::InvalidFeatureFlagError, "Feature flag is not valid" unless valid?
    end

    def valid?
      name.present? && type.present? && !default_enabled.nil?
    end

    def valid_usage!(user_default_enabled:)
      # We accept an array of defaults as some features are undefined
      # and have `default_enabled: true/false`
      unless Array(default_enabled).include?(user_default_enabled)
        # Raise exception in test and dev
        raise Feature::InvalidFeatureFlagError, "the `default_enabled` of `#{key}` is not equal to config: " \
          "#{user_default_enabled} vs #{default_enabled}"
      end
    end

    def to_h
      attributes
    end

    def save_to_file!(path)
      valid!

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, attributes.deep_stringify_keys.to_yaml)
    end

    def self.paths
      @paths ||= [Rails.root.join('config', 'feature_flags', '*.yml')]
    end

    def self.load_from_file(path)
      definition = File.read(path)
      definition = YAML.safe_load(definition)
      definition.deep_symbolize_keys!
      name = definition.fetch(:name)

      unless File.basename(path) == name + ".yml"
        raise ArgumentError, "Invalid path, expected: `#{name}.yml`"
      end

      self.new(definition).tap(&:valid!)
    rescue => e
      raise Feature::InvalidFeatureFlagError, "Invalid definition at `#{path}`: #{e.message}"
    end

    def self.definitions
      @definitions ||= {}
    end

    def self.load_all!
      paths.each do |glob_path|
        Dir.glob(glob_path).each do |path|
          definition = load_from_file(path)
          # TODO: enable
          # if @definitions.include?(name.to_sym)
          #   raise InvalidFeatureFlagError, "Feature flag '#{name}' is already defined"
          # end
          definitions[definition.key] = definition
        end
      end

      definitions
    end

    def self.lazily_create!(key, default_enabled:)
      return unless lazily_create?
      return if definitions[key.to_sym]

      dir = File.dirname(feature_flags_paths.last)
      path = File.join(dir, key.to_s + '.yml')
      return if File.exist?(path)

      Feature::Definition.new(
        name: key.to_s,
        type: 'other',
        default_enabled: default_enabled
      ).save!(path)

      load!(path)
    end

    def self.valid_usage!(key, default_enabled:)
      return unless validate_usage?

      lazily_create!(key, default_enabled: default_enabled)

      definition = definitions[key.to_sym]
      raise InvalidFeatureFlagError, "missing feature definition for `#{key}`" unless definition

      definition.valid_usage!(user_default_enabled: default_enabled)
    end

    def self.validate_usage?
      strong_memoize(:validate_usage) do
        Gitlab::Utils.to_boolean(ENV.fetch('VALIDATE_FEATURE_FLAG', '1').to_s)
      end
    end

    def self.lazily_create?
      strong_memoize(:lazily_create) do
        Gitlab::Utils.to_boolean(ENV.fetch('LAZILY_CREATE_FEATURE_FLAG', '1').to_s)
      end
    end
  end
end

Feature::Definition.prepend_if_ee('EE::Feature::Definition')
