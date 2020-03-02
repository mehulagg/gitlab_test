# frozen_string_literal: true

class WikiPageMeta < ApplicationRecord
  belongs_to :project

  has_many :slugs, class_name: 'WikiPageSlug', inverse_of: :wiki_page_meta
  has_many :events, as: :target, dependent: :delete_all # rubocop:disable Cop/ActiveRecordDependent

  validates :canonical_slug, presence: true,
                             uniqueness: { scope: :project_id }
  validates :title, presence: true
  validates :project, presence: true

  alias_method :resource_parent, :project

  # Return the (updated) WikiPageMeta record for a given wiki page
  #
  # If none is found, then a new record is created.
  def self.for_wiki_page(slug, title, project)
    create_with(title: title).find_or_create_by(canonical_slug: slug, project: project).tap do |meta|
      meta.assign_attributes(title: title)
      meta.save! if meta.changed?
    end
  end

  def update_slug(slug)
    unless slugs.where(slug: slug).exists?
      slugs.create(slug: slug)
    end

    return if canonical_slug == slug

    update(canonical_slug: slug)
  end
end
