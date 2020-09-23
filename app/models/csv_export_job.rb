# frozen_string_literal: true

class CsvExportJob < ApplicationRecord
  include FileStoreMounter

  belongs_to :user

  validates :user, :jid, :status, presence: true

  mount_file_store_uploader AttachmentUploader

  EXPORT_TYPES = {
    merge_commit_report: 1
  }.with_indifferent_access.freeze

  enum user_type: EXPORT_TYPES

  state_machine :status, initial: :queued do
    event :start do
      transition [:queued] => :started
    end

    event :finish do
      transition [:started] => :finished
    end

    event :fail_op do
      transition [:queued, :started] => :failed
    end

    state :queued, value: 0
    state :started, value: 1
    state :finished, value: 2
    state :failed, value: 3
  end

  def retrieve_upload(_identifier, paths)
    Upload.find_by(model: self, path: paths)
  end
end
