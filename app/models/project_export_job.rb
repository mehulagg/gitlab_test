# frozen_string_literal: true

class ProjectExportJob < ApplicationRecord
  belongs_to :project

  validates :project, :jid, :status, presence: true

  state_machine :status, initial: :none do
    event :start do
      transition [:none] => :started
    end

    event :finish do
      transition [:started] => :finished
    end

    event :fail_op do
      transition [:started] => :failed
    end

    state :none, value: 0
    state :started, value: 1
    state :finished, value: 2
    state :failed, value: 3
  end
end
