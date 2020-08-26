# frozen_string_literal: true

module EE
  module FormHelper
    def issue_supports_multiple_assignees?
      current_board_parent.feature_available?(:multiple_issue_assignees)
    end

    def merge_request_supports_multiple_assignees?
      @merge_request&.allows_multiple_assignees?
    end

    def reviewers_dropdown_options(issuable_type)
      dropdown_data = {
        toggle_class: 'js-user-search js-assignee-search js-multiselect js-save-user-data',
        title: 'Select reviewer',
        filter: true,
        dropdown_class: 'dropdown-menu-user dropdown-menu-selectable dropdown-menu-reviewer',
        placeholder: _('Search users'),
        data: {
          first_user: current_user&.username,
          null_user: true,
          current_user: true,
          project_id: (@target_project || @project)&.id, field_name: "#{issuable_type}[reviewer_ids][]",
          default_label: 'Unassigned',
          'max-select': 1,
          'dropdown-header': 'Reviewer',
          multi_select: true,
          'input-meta': 'name',
          'always-show-selectbox': true,
          current_user_info: UserSerializer.new.represent(current_user)
        }
      }

      type = issuable_type.to_s

      if type == 'merge_request' && merge_request_supports_reviewers?
        dropdown_data = multiple_reviewers_dropdown_options(dropdown_data)
      end

      dropdown_data
    end

    def multiple_reviewers_dropdown_options(options)
      new_options = options.dup

      new_options[:title] = 'Select reviewer(s)'
      new_options[:data][:'dropdown-header'] = 'Reviewer(s)'
      new_options[:data].delete(:'max-select')

      new_options
    end

    def merge_request_supports_reviewers?
      @merge_request&.allows_reviewers?
    end
  end
end
