# frozen_string_literal: true

module QA
  module Page
    module Component
      module DropdownFilter
        def filter_and_select(item)
          page.has_css?('.dropdown-input-field', wait: QA::Support::Repeater::DEFAULT_MAX_WAIT_TIME)

          find('.dropdown-input-field').set(item)
          click_link item

          page.has_no_css?('.dropdown-loading', wait: QA::Support::Repeater::DEFAULT_MAX_WAIT_TIME)
        end
      end
    end
  end
end
