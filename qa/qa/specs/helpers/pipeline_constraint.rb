# frozen_string_literal: true

require 'rspec/core'

module QA
  module Specs
    module Helpers
      module PipelineConstraint
        include RSpec::Core::Pending

        extend self

        def configure_rspec
          require 'pry'; binding.pry
          RSpec.configure do |config|
            config.before do |example|
              if example.metadata.key?(:only)
                skip('Test is not compatible with this pipeline') unless QA::Runtime::Env.ci_project_name =~ example.metadata[:only_run_in_pipeline]
              end
            end
          end
        end
      end
    end
  end
end
