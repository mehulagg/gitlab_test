# frozen_string_literal: true

module Quality
  class TestCase < ApplicationRecord
    include CacheMarkdownField
    include StripAttribute
    include AtomicInternalId

    cache_markdown_field :title, pipeline: :single_line
    cache_markdown_field :description, pipeline: :description

    strip_attributes :title

    belongs_to :project, inverse_of: :test_cases

    has_internal_id :iid, scope: :project, init: ->(s) { s&.project&.test_cases&.maximum(:iid) }

    validates :project, :title, presence: true
    validates :title, length: { maximum: Issuable::TITLE_LENGTH_MAX }
    validates :title_html, length: { maximum: Issuable::TITLE_HTML_LENGTH_MAX }, allow_blank: true

    enum state: { active: 1, archived: 2 }
  end
end
