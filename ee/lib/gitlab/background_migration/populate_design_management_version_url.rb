# frozen_string_literal: true

# This migration reads the SHA from versions, finds the corresponding
# commit, and then writes the author information for that commit back
# to the versions table under the `author_id` column.
class Gitlab::BackgroundMigration::ExtractServicesUrl
  # We cannot use the app/model version here (an in any case it is
  # EE code), so we have to duplicate the functionality we want.
  class Version < ActiveRecord::Base
    self.table_name = 'design_management_versions'

    # We are relying on some model pieces, including project and issue.
    # These are so foundational, that if the dataset changes underneath
    # us we have very big issues to be concerned about.
    def current_commit
      issue = Issue.find(version.issue_id)

      issue&.project&.design_repository&.commit(version.sha)
    end
  end

  def perform(version_id)
    version = Version.select(:sha, :issue_id)
      .where('author_id IS NOT NULL')
      .find_by(id: version_id)

    return unless version # removed or already processed

    commit = version.current_commit
    author_id = commit&.author&.id

    service.update(author_id: author_id) if author_id.present?
  end
end
