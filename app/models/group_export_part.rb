# frozen_string_literal: true

class GroupExportPart < ApplicationRecord
  include AfterCommitQueue

  belongs_to :export, class_name: 'GroupExport', foreign_key: :group_export_id

  serialize :params, Serializers::JSON # rubocop:disable Cop/ActiveRecordSerialize

  validates :params, :name, presence: true

  scope :created, -> { where(status: self.state_machines[:status].states[:created].value) }

  state_machine :status, initial: :created do
    state :created,   value: 0
    state :scheduled, value: 3
    state :started,   value: 6
    state :finished,  value: 9
    state :failed,    value: -1
    state :aborted,   value: -2

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

    after_transition any => :failed do |state, transition|
      state.update(status_reason: transition.args.first)
    end
  end
end
