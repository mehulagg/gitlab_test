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
        title: 'Select reviewer(s)',
        filter: true,
        dropdown_class: 'dropdown-menu-user dropdown-menu-selectable dropdown-menu-reviewer',
        placeholder: _('Search users'),
        data: {
          first_user: current_user&.username,
          null_user: true,
          current_user: true,
          project_id: (@target_project || @project)&.id, field_name: "#{issuable_type}[reviewer_ids][]",
          default_label: 'Unassigned',
          'dropdown-header': 'Reviewer(s)',
          multi_select: true,
          'input-meta': 'name',
          'always-show-selectbox': true,
          current_user_info: UserSerializer.new.represent(current_user)
        }
      }
    end
  end
end
