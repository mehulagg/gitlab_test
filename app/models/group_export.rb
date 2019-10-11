# frozen_string_literal: true

class GroupExport < ApplicationRecord
  include AfterCommitQueue

  belongs_to :group, inverse_of: :exports
  has_many :parts, class_name: 'GroupExportPart', autosave: true

  validates :group, presence: true

  mount_uploader :export_file, ImportExportUploader

  state_machine :status, initial: :created do
    state :created,  value: 0
    state :started,  value: 3
    state :uploaded, value: 4
    state :finished, value: 9
    state :failed,   value: -1

    event :start do
      transition created: :started
    end

    event :upload do
      transition started: :uploaded
    end

    event :finish do
      transition uploaded: :finished
    end

    event :fail_op do
      transition [:created, :started] => :failed
    end

    after_transition created: :started do |state, _|
      state.run_after_commit do
        Gitlab::ImportExport::Group::Parts::Batcher.process_next_batch(state.id)
      end
    end

    after_transition any => :failed do |state, transition|
      state.update(status_reason: transition.args.first)

      state.parts.created.each do |part|
        part.abort_op(reason: _('One or more export parts failed'))
      end
    end
  end
end
