# frozen_string_literal: true

module Ci
  module Builds
    module Dotenv
      class Variables < ApplicationRecord
        include NewHasVariable

        self.table_name = 'ci_build_dotenv_variables'

        belongs_to :build, class_name: 'Ci::Build', foreign_key: :build_id, inverse_of: :dotenv_variables

        def variable_type
          variable_types[:env_var]
        end
      end
    end
  end
end
