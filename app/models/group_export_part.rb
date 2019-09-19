# frozen_string_literal: true

class GroupExportPart < ApplicationRecord
  include AfterCommitQueue

  belongs_to :export, class_name: 'GroupExport', foreign_key: :group_export_id

  serialize :params, Serializers::JSON # rubocop:disable Cop/ActiveRecordSerialize

  validates :params, :name, presence: true

  scope :created, -> { where(status: 'created') }

  state_machine :status, initial: :created do
    event :schedule do
      transition [:created] => :scheduled
    end

    event :start do
      transition scheduled: :started
    end

    event :finish do
      transition started: :finished
    end

    event :fail_op do
      transition [:scheduled, :started] => :failed
    end

    event :abort_op do
      transition [:created, :scheduled] => :aborted
    end

    state :created
    state :scheduled
    state :started
    state :finished
    state :aborted
    state :failed

    after_transition created: :scheduled do |state, _|
      state.run_after_commit do
        job_id = Gitlab::ImportExport::Group::ExportPartWorker.perform_async(state.export.id, state.id)

        state.update(jid: job_id) if job_id
      end
    end

    after_transition scheduled: :started do |state, _|
      state.run_after_commit do
        Gitlab::ImportExport::Group::Exporters::Exporter.for(state).export
      end
    end

    after_transition any => :failed do |state, transition|
      error = transition.args.first || _('Unknown error during Group Export part')

      state.update(last_error: error)
    end
  end
end
