# frozen_string_literal: true

class GroupExport < ApplicationRecord
  include AfterCommitQueue

  belongs_to :group, inverse_of: :exports
  has_many :parts, class_name: 'GroupExportPart', autosave: true

  validates :group, presence: true

  state_machine :status, initial: :created do
    event :start do
      transition created: :started
    end

    event :finish do
      transition started: :finished
    end

    event :fail_op do
      transition [:created, :started] => :failed
    end

    state :created
    state :started
    state :finished
    state :failed

    after_transition created: :started do |state, _|
      state.run_after_commit do
        batcher = Gitlab::ImportExport::Group::Parts::Batcher.new(state.id)
        batcher.process_next_batch
      end
    end

    after_transition any => :failed do |state, transition|
      error = transition.args.first || _('Unknown error during Group Export')

      state.update(last_error: error)
    end
  end
end
