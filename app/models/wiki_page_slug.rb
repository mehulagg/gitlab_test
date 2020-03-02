# frozen_string_literal: true

class WikiPageSlug < ApplicationRecord
  belongs_to :wiki_page_meta

  validates :slug, presence: true, uniqueness: { scope: :wiki_page_meta_id }
end
