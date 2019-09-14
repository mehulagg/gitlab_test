# frozen_string_literal: true

module EE
  module TrialHelper
    def company_size_options_for_select(selected = 0)
      options_for_select([
        ['Please select', 0],
        ['1 - 99', 1],
        ['100 - 499', 2],
        ['500 - 1,999', 3],
        ['2,000 - 9,999', 4],
        ['10,000 +', 5]
      ], selected)
    end

    def number_of_users_options_for_select(selected = 0)
      options_for_select([
        ['Please select', 0],
        ['1 - 49', 1],
        ['50 - 99', 2],
        ['100 - 249', 3],
        ['250 - 499', 4],
        ['500 +', 5]
      ], selected)
    end

    def namespace_options_for_select
      groups = current_user.manageable_groups.map { |g| [g.name, g.id] }
      users = [[current_user.namespace.name, current_user.namespace.id]]

      grouped_options = {
        'New' => [['Create group', 0]],
        'Groups' => groups,
        'Users' => users
      }

      grouped_options_for_select(grouped_options, nil, prompt: 'Please select')
    end
  end
end
