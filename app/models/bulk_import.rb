class BulkImport < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :source_host, :private_token, presence: true
end
