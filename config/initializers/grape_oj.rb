# frozen_string_literal: true

require "oj"
require "scientist"
require "scientist/experiment"

Oj.default_options = { mode: :rails }

class OjExperiment
  include Scientist::Experiment

  attr_accessor :name

  def initialize(name:)
    @name = name
  end

  def enabled?
    return false if Rails.env.test?

    Feature.enabled?(:oj_json_dumping_experiment, default_enabled: true)
  end

  def publish(result)
    histogram.observe(
      { method: "grape_default", matches: result.matched?, ignored: result.ignored? },
      result.control.duration
    )

    histogram.observe(
      { method: "oj", matches: result.matched?, ignored: result.ignored? },
      result.candidates.first.duration
    )
  end

  private

  def histogram
    @histogram ||= Gitlab::Metrics.histogram(
      :grape_json_dump_duration,
      "Time taken to dump an object to JSON"
    )
  end
end

module Scientist::Experiment
  def self.new(name)
    OjExperiment.new(name: name)
  end
end

module Grape
  module Formatter
    module Json
      class << self
        def call(object, env)
          Scientist.run(name: "grape-json-dumping") do |e|
            e.context object: object
            e.use { old_implementation(object, env) }
            e.try { new_implementation(object, env) }
          end
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
