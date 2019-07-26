# frozen_string_literal: true

module DesignManagement
  class Design < ApplicationRecord
    include Noteable
    include Gitlab::FileTypeDetection

    belongs_to :project, inverse_of: :designs
    belongs_to :issue

    has_many :design_versions
    has_many :versions, through: :design_versions, class_name: 'DesignManagement::Version', inverse_of: :designs
    # This is a polymorphic association, so we can't count on FK's to delete the
    # data
    has_many :notes, as: :noteable, dependent: :delete_all # rubocop:disable Cop/ActiveRecordDependent

    validates :project, :issue, :filename, presence: true
    validates :filename, uniqueness: { scope: :issue_id }
    validate :validate_file_is_image

    scope :visible_at_version, -> (version) do
      created_before_version = DesignManagement::DesignVersion.select(1)
                               .where("#{table_name}.id = #{DesignManagement::DesignVersion.table_name}.design_id")
                               .where("#{DesignManagement::DesignVersion.table_name}.version_id <= ?", version)

      where('EXISTS(?)', created_before_version)
    end

    def new_design?
      versions.none?
    end

    def full_path
      @full_path ||= File.join(DesignManagement.designs_directory, "issue-#{issue.iid}", filename)
    end

    # I think there's a problem here that we only show the diff_refs for the latest
    # version, this means as the version changes, this will change.
    def diff_refs
      return if new_design?

      @diff_refs ||= repository.commit(head_version.sha).diff_refs
    end

    # TODO this is using `repository.commit(head_version.sha)` from diff_refs
    # is there a way to do this by memoizing commit data? it won't change.
    # Or actually commit should be lazy on Version or something...!
    def diffs(diff_options = nil)
      # Using a commit...
      project.using_repository(:design) do
        Gitlab::Diff::FileCollection::Commit.new(repository.commit(head_version.sha), diff_options: diff_options)
      end

      # (compare, project:, diff_options:, diff_refs: nil)
      # Gitlab::Diff::FileCollection::Compare.new(
      #   compare,
      #   project: project,
      #   diff_options: diff_options,
      #   diff_refs: diff_refs
      # )
    end

    def repository
      project.design_repository
    end

    private

    # def compare
    # end

    def head_version
      @head_sha ||= versions.ordered.first
    end

    def validate_file_is_image
      unless image?
        message = _("Only these extensions are supported: %{extension_list}") % {
          extension_list: Gitlab::FileTypeDetection::IMAGE_EXT.join(", ")
        }
        errors.add(:filename, message)
      end
    end
  end
end
