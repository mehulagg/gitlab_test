# frozen_string_literal: true

class Feature
  class Definition
    include ::Feature::Shared

    attr_reader :path
    attr_reader :attributes

    PARAMS.each do |param|
      define_method(param) do
        attributes[param]
      end
    end

    def initialize(path, opts = {})
      @path = path
      @attributes = {}

      # assign nil, for all unknown opts
      PARAMS.each do |param|
        @attributes[param] = opts[param]
      end
    end

    def key
      name.to_sym
    end

    def valid!
      unless name.present?
        raise Feature::InvalidFeatureFlagError, "Feature flag is missing name"
      end

      unless path.present?
        raise Feature::InvalidFeatureFlagError, "Feature flag '#{name}' is missing path"
      end

      unless type.present?
        raise Feature::InvalidFeatureFlagError, "Feature flag '#{name}' is missing type. Ensure to update #{path}"
      end

      unless Definition::TYPES.include?(type.to_sym)
        raise Feature::InvalidFeatureFlagError, "Feature flag '#{name}' type '#{type}' is invalid. Ensure to update #{path}"
      end

      unless File.basename(path) == name + ".yml"
        raise Feature::InvalidFeatureFlagError, "Feature flag '#{name}' has an invalid path: '#{path}'. Ensure to update #{path}"
      end

      unless File.basename(File.dirname(path)) == type
        raise Feature::InvalidFeatureFlagError, "Feature flag '#{name}' has an invalid type: '#{path}'. Ensure to update #{path}"
      end

      if default_enabled.nil?
        raise Feature::InvalidFeatureFlagError, "Feature flag '#{name}' is missing default_enabled. Ensure to update #{path}"
      end
    end

    def valid_usage!(user_type:, user_default_enabled:)
      unless Array(type).include?(user_type.to_s)
        # Raise exception in test and dev
        raise Feature::InvalidFeatureFlagError, "the `type:` of `#{key}` is not equal to config: " \
          "#{user_type} vs #{type}. Ensure to use valid type in #{path} or ensure that you use " \
          "a valid syntax: #{TYPES.dig(type, :example)}"
      end

      # We accept an array of defaults as some features are undefined
      # and have `default_enabled: true/false`
      unless Array(default_enabled).include?(user_default_enabled)
        # Raise exception in test and dev
        raise Feature::InvalidFeatureFlagError, "the `default_enabled` of `#{key}` is not equal to config: " \
          "#{user_default_enabled} vs #{default_enabled}. Ensure to update #{path}"
      end
    end

    def to_h
      attributes
    end

    def save!
      valid!

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, attributes.deep_stringify_keys.to_yaml)
    end

    class << self
      def paths
        @paths ||= [Rails.root.join('config', 'feature_flags', '**', '*.yml')]
      end

      def load_from_file(path)
        definition = File.read(path)
        definition = YAML.safe_load(definition)
        definition.deep_symbolize_keys!

        self.new(path, definition).tap(&:valid!)
      rescue => e
        raise Feature::InvalidFeatureFlagError, "Invalid definition at `#{path}`: #{e.message}"
      end

      def definitions
        @definitions ||= {}
      end

      def load_all_from_path!(glob_path)
        Dir.glob(glob_path).each do |path|
          definition = load_from_file(path)

          if previous = definitions[definition.key]
            raise InvalidFeatureFlagError, "Feature flag '#{name}' is already defined in '#{previous.path}'"
          end

          definitions[definition.key] = definition
        end
      end

      def load_all!
        definitions.clear

        paths.each do |glob_path|
          load_all_from_path!(glob_path)
        end

        definitions
      end

      def valid_usage!(key, type:, default_enabled:)
        if definition = definitions[key.to_sym]
          definition.valid_usage!(user_type: type, user_default_enabled: default_enabled)
        elsif !self::TYPES.dig(type, :optional)
          raise InvalidFeatureFlagError, "Missing feature definition for `#{key}`"
        end
      end
    end
  end
end

Feature::Definition.prepend_if_ee('EE::Feature::Definition')
