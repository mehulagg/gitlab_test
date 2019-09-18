# frozen_string_literal: true
# rubocop: disable all

require 'logger'

# Disables closed issues in gitlab-foss repository
# Disabling means:
#   set milestone to none
#   lock discussions
#   remove labels
#   remove epic if any
#   remove weight
#   remove due date

# Prevent creating system notes
module Issuable
  class CommonSystemNotesService < ::BaseService
    def execute(*)
      # NOOP
    end
  end
end

module EE
  module Issuable
    module CommonSystemNotesService
      def execute(*)
        # NOOP
      end
    end
  end
end

MOVE_DATE = "2019-09-09".to_date.freeze
MOVE_NOTE_TEXT = "GitLab is moving all development for both GitLab Community Edition"

issue_update_params = {
  milestone_id: nil,
  discussion_locked: true,
  weight: nil,
  due_date: nil,
  label_ids: [""],
  skip_milestone_email: true
}

logger = Logger.new(STDOUT)
user = User.find_by(username: 'gitlab-bot')
source_project = Project.find_by_full_path('gitlab-org/gitlab-foss')

moved_issues_ids =
  Note.select(:noteable_id)
    .where(project: source_project)
    .where(noteable_type: 'Issue')
    .where('created_at >= ?', MOVE_DATE)
    .where('note LIKE ?', "%#{MOVE_NOTE_TEXT}%")

issues = Issue.where(id: moved_issues_ids)

issues.each_with_index do |issue, index|
  # In case the script fails in the middle this prevents
  # running queries again for the already disabled ones.
  # Do not check for label_ids or epic_issue because they execute queries.
  next if issue.milestone_id.nil? && issue.weight.nil? && issue.due_date.nil? && issue.discussion_locked?

  logger.info("[#{index + 1}]: Disabling issue https://gitlab.com/gitlab-org/gitlab-foss/issues/#{issue.iid}")

  retried = 0

  begin
    Issues::UpdateService.new(source_project, user, issue_update_params).execute(issue)

    if epic_issue = issue.epic_issue
      EpicIssues::DestroyService.new(epic_issue, user).execute
    end

  rescue => error
    next if retried == 3

    logger.error("Retrying after error: #{error.message}")
    logger.error("Retrying after error: #{error.backtrace}")

    retried += 1

    retry
  end
end




