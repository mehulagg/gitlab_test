# frozen_string_literal: true

module EE
  module TrialHelper
    def company_size_options_for_select(selected = 0)
      options_for_select([
        [_('Please select'), 0],
        ['1 - 99', '1-99'],
        ['100 - 499', '100-499'],
        ['500 - 1,999', '500-1,999'],
        ['2,000 - 9,999', '2,000-9,999'],
        ['10,000 +', '10,000+']
      ], selected)
    end
    def namespace_options_for_select

      groups = current_user.manageable_groups.map { |g| [g.name, g.id] }
      users = [[current_user.namespace.name, current_user.namespace.id]]

      grouped_options = {
        'New' => [[_('Create group'), 0]],
        'Groups' => groups,
        'Users' => users
      }

      grouped_options_for_select(grouped_options, nil, prompt: _('Please select'))
    end
  end
end
