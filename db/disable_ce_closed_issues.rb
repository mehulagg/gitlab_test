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

MOVE_DATE = "2019-09-09".to_date.freeze
MOVE_NOTE_TEXT = "GitLab is moving all development for both GitLab Community Edition"
BATCH_SIZE = 100.freeze
BATCH_WAIT = 3.freeze

rows_updated = BATCH_SIZE

Issue.include(EachBatch)

issue_update_params = {
  milestone_id: nil,
  discussion_locked: true,
  weight: nil,
  due_date: nil
}

logger = Logger.new(STDOUT)
user_id = User.find_by(username: 'gitlab-bot').id
source_project_id = Project.find_by_full_path('gitlab-org/gitlab-foss').id

moved_issues =
  ActiveRecord::Base.transaction do
    ActiveRecord::Base.connection.execute("SET LOCAL statement_timeout = '1min'")

    Note.select(:noteable_id)
      .where(project_id: source_project_id)
      .where(author_id: user_id)
      .where(noteable_type: 'Issue')
      .where('created_at >= ?', MOVE_DATE)
      .where('note LIKE ?', "%#{MOVE_NOTE_TEXT}%")
  end

issues = Issue.where(id: moved_issues)
issues_count = issues.count

issues.each_batch(of: BATCH_SIZE) do |batch|
  retried = 0

  begin
    logger.info("Processing #{rows_updated} of #{issues_count}....")

    batch.update_all(issue_update_params)
    EpicIssue.where(issue_id: batch).delete_all
    LabelLink.where(target_type: 'Issue', target_id: batch).delete_all

    logger.info("Waiting #{BATCH_WAIT} seconds for next batch.")

    sleep BATCH_WAIT

    rows_updated += BATCH_SIZE
  rescue => error
    next if retried == 3

    logger.error("Retrying after error: #{error.message}")
    logger.error("Retrying after error: #{error.backtrace}")

    retried += 1

    retry
  end
end
