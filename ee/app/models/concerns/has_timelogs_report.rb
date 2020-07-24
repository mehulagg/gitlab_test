# frozen_string_literal: true

module HasTimelogsReport
  extend ActiveSupport::Concern

  def timelogs(start_time, end_time)
    @timelogs ||= timelogs_for(self, start_time, end_time)
  end

  def user_can_access_group_timelogs?(current_user)
    return unless feature_available?(:group_timelogs)

    Ability.allowed?(current_user, :read_group_timelogs, group)
  end

  private

  def timelogs_for(parent, start_time, end_time)
    method_name = if group_parent?(parent)
                    'for_issues_in_group'
                  else
                    'for_issues_in_project'
                  end

    Timelog.between_times(start_time, end_time)
      .public_send(method_name, parent) # rubocop:disable GitlabSecurity/PublicSend
  end

  def group
    strong_memoize(:group) do
      group_parent?(self) ? self : self.group
    end
  end

  def group_parent?(parent)
    parent.is_a?(Group)
  end
end
