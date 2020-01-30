# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        class PersistentRule
          def self.fabricate(source)
            klass_name = "Chain::PersistentRules::#{source.camelize}"

            Object.const_defined?(klass_name) ?
              klass_name.constantize : Chain::PersistentRules::Default.new
          end
        end
      end
    end
  end
end
