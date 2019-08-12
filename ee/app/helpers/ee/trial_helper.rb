# frozen_string_literal: true

module EE
  module TrialHelper
    def employees_count_options_for_select
      options_for_select([
        ['Please select', 0],
        ['1 - 99', 1],
        ['100 - 499', 2],
        ['500 - 1,999', 3],
        ['2,000 - 9,999', 4],
        ['10,000 +', 5],
      ], 0)
    end

    def trial_users_count_options_for_select
      options_for_select([
        ['Please select', 0],
        ['1 - 49', 1],
        ['50 - 99', 2],
        ['100 - 249', 3],
        ['250 - 499', 4],
        ['500 +', 5],
      ], 0)
    end

    def namespace_options_for_select
      # TODO(vitaly): current_user is missing
      options_for_select([
        ['Please select', 0],
        ['New Group', 1],
      ], 0)
    end
  end
end
