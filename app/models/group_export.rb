# frozen_string_literal: true

class GroupExport < ApplicationRecord
  include AfterCommitQueue

  belongs_to :group, inverse_of: :exports
  has_many :parts, class_name: 'GroupExportPart', autosave: true

  validates :group, presence: true

  state_machine :status, initial: :created do
    state :created,  value: 0
    state :started,  value: 3
    state :finished, value: 9
    state :failed,   value: -1

    event :start do
      transition created: :started
    end

    event :finish do
      transition started: :finished
    end

    event :fail_op do
      transition [:created, :started] => :failed
    end

    after_transition any => :failed do |state, transition|
      state.update(status_reason: transition.args.first)
    end
  end
end
