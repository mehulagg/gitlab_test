# frozen_string_literal: true

class LabelLink < ApplicationRecord
  include BulkInsertSafe
  include Importable

  belongs_to :target, polymorphic: true, inverse_of: :label_links # rubocop:disable Cop/PolymorphicAssociations
  belongs_to :label

  validates :target, presence: true, unless: :importing?
  validates :label, presence: true, unless: :importing?

  scope :for_issues, -> { where(target_type: 'Issue') }
  scope :created_after, ->(from_date) { where('label_links.created_at >= ?', from_date) }
  scope :with_label_attributes, ->(label_attributes) { joins(:label).where(labels: label_attributes) }
end
