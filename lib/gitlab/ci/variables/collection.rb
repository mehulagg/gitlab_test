# frozen_string_literal: true

module Gitlab
  module Ci
    module Variables
      class Collection
        include Enumerable

        attr_reader :auth

        def initialize(variables = [], auth: nil)
          @variables = []
          @auth = auth

          variables.each { |variable| self.append(variable) }
        end

        def append(resource)
          tap { @variables.append(Collection::Item.fabricate(resource, auth: auth)) }
        end

        def concat(resources)
          return self if resources.nil?

          tap { resources.each { |variable| self.append(variable) } }
        end

        def each
          @variables.each { |variable| yield variable }
        end

        def +(other)
          self.class.new.tap do |collection|
            self.each { |variable| collection.append(variable) }
            other.each { |variable| collection.append(variable) }
          end
        end

        def to_runner_variables(user, project)
          self.select { |variable| can?(user, variable.auth, project) }.map(&:to_runner_variable)
        end

        def to_hash(user, project)
          self.to_runner_variables(user)
            .map { |env| [env.fetch(:key), env.fetch(:value)] }
            .to_h.with_indifferent_access
        end
      end
    end
  end
end
