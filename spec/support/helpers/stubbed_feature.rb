# frozen_string_literal: true

# Extend the Feature class with the ability to stub feature flags.
module StubbedFeature
  extend ActiveSupport::Concern

  class_methods do
    attr_writer :stub, :validate_usage

    def stub?
      @stub.nil? ? true : @stub
    end

    def validate_usage?
      @validate_usage.nil? ? true : @validate_usage
    end

    # Wipe any previously set feature flags.
    def reset_flipper
      @flipper = nil
    end

    # Replace #flipper method with the optional stubbed/unstubbed version.
    def flipper
      if stub?
        @flipper ||= Flipper.new(Flipper::Adapters::Memory.new)
      else
        super
      end
    end

    # Replace #enabled? method with the optional stubbed/unstubbed version.
    def enabled?(*args)
      feature_flag = super(*args)
      return feature_flag unless stub?

      # If feature flag is not persisted we mark the feature flag as enabled
      # We do `m.call` as we want to validate the execution of method arguments
      # and a feature flag state if it is not persisted
      unless Feature.persisted_name?(args.first)
        feature_flag = true
      end

      feature_flag
    end

    def check_feature_flags_definition?
      super && validate_usage?
    end
  end
end
