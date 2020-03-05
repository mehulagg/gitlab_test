# frozen_string_literal: true

require "oj"

module Grape
  module Formatter
    module Json
      class << self
        def call(object, env)
          experiment = Gitlab::Experiments::Oj.new("grape-json-dumping")
          experiment.context object: object
          experiment.use { old_implementation(object, env) }
          experiment.try { new_implementation(object, env) }
          experiment.run
        end

        def old_implementation(object, _env)
          return object.to_json if object.respond_to?(:to_json)

          ::Grape::Json.dump(object)
        end

        def new_implementation(object, _env)
          Oj.dump(object)
        end
      end
    end
  end
end
