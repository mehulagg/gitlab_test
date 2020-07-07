# frozen_string_literal: true

class SuggestionPolicy < BasePolicy
  delegate { @subject.project }

  condition(:can_push_to_branch) do
    Gitlab::UserAccessProject.new(@user, project: @subject.project).can_push_to_branch?(@subject.branch)
  end

  rule { can_push_to_branch }.enable :apply_suggestion
end
