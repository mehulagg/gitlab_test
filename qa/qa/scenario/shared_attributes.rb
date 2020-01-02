# frozen_string_literal: true

module QA
  module Scenario
    module SharedAttributes
      include Bootable

      attribute :gitlab_address, '--address URL', 'Address of the instance to test'
      attribute :enable_feature, '--enable-feature FEATURE_FLAG', 'Enable a feature before running tests'
      attribute :parallel, '--parallel', 'Execute tests in parallel'
      attribute :loop, '--loop', 'Execute test repeatedly'
      attribute :dry_run, '--dry-run', 'Passes `--dry-run` to RSpec allowing tests to be listed without running them'
    end
  end
end
