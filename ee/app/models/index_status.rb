# frozen_string_literal: true

class IndexStatus < ApplicationRecord
  include ::ShaAttribute

  belongs_to :project
  belongs_to :elasticsearch_index

  sha_attribute :last_wiki_commit

  validates :project_id, uniqueness: { scope: :elasticsearch_index_id }, presence: true
  validates :elasticsearch_index_id, presence: true

  scope :for_project, ->(project_id) { where(project_id: project_id) }
  scope :for_index, ->(index_id) { where(elasticsearch_index_id: index_id) }
  scope :with_indexed_data, -> { where.not(last_commit: nil, indexed_at: nil) }
end
