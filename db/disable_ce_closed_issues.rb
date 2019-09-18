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
MOVE_DATE = "2019-09-09".to_date.freeze
MOVE_NOTE_TEXT = "GitLab is moving all development for both GitLab Community Edition"

issue_update_params = {
  milestone_id: nil,
  discussion_locked: true,
  weight: nil,
  due_date: nil
}

logger = Logger.new(STDOUT)
user_id = User.find_by(username: 'gitlab-bot').id
source_project_id = Project.find_by_full_path('gitlab-org/gitlab-foss').id

moved_issues_ids =
  Note.select(:noteable_id)
    .where(project_id: source_project_id)
    .where(author_id: user_id)
    .where(noteable_type: 'Issue')
    .where('created_at >= ?', MOVE_DATE)
    .where('note LIKE ?', "%#{MOVE_NOTE_TEXT}%")

issues = Issue.where(id: moved_issues_ids)

issues.each_with_index do |issue, index|
  # In case the script fails in the middle this prevents
  # running queries again for the already disabled ones.
  # Do not check for label_ids or epic_issue because they execute queries.
  next if issue.milestone_id.nil? && issue.weight.nil? && issue.due_date.nil? && issue.discussion_locked?

  logger.info("[#{index + 1}]-------: Disabling issue https://gitlab.com/gitlab-org/gitlab-foss/issues/#{issue.iid}")

  retried = 0

  begin
    issue.update(issue_update_params)
    issue.epic_issue&.destroy
    issue.label_links&.destroy_all

  rescue => error
    next if retried == 3

    logger.error("Retrying after error: #{error.message}")
    logger.error("Retrying after error: #{error.backtrace}")

    retried += 1

    retry
  end
end




