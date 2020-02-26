# frozen_string_literal: true

module Ci
  module Builds
    class DotenvVariable < ApplicationRecord
      include NewHasVariable

      MAX_ACCEPTABLE_VARIABLES_COUNT = 10

      self.table_name = 'ci_build_dotenv_variables'

      belongs_to :build, class_name: 'Ci::Build', foreign_key: :build_id,
        inverse_of: :dotenv_variables

      validates :key, uniqueness: { scope: :build_id }
      validate :acceptable_count

      private

      def acceptable_count
        if build && build.dotenv_variables.size > MAX_ACCEPTABLE_VARIABLES_COUNT
          errors.add(:variables,
            "are not allowed to be stored more than #{MAX_ACCEPTABLE_VARIABLES_COUNT}")
        end
      end
    end
  end
end
