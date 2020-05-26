# frozen_string_literal: true

# IssuableFinder::ByCommentersFinder class
#
# Used to filter issuable collections by commenters

class IssuableFinder
  class ByCommentersFinder
    attr_reader :usernames, :ids, :table_name

    def initialize(issuable_class, usernames, ids)
      @table_name = issuable_class.table_name
      @usernames = usernames.to_a.map(&:to_s)
      @ids = ids
    end

    def execute(items)
      if usernames.present?
        by_author_names(items)
      elsif ids.present?
        by_author_ids(items)
      else
        items
      end
    end

    private

    # rubocop:disable CodeReuse/ActiveRecord
    def by_note_attrs(items, attrs)
      items.joins(notes: :author)
        .where(notes: { system: false }, users: attrs)
        .group("#{table_name}.id").distinct
    end

    def by_author_names(items)
      by_note_attrs(items, { username: usernames })
        .having("ARRAY_AGG(TEXT(users.username)) @> ARRAY[?]", usernames)
    end

    def by_author_ids(items)
      by_note_attrs(items, { id: ids })
        .having("ARRAY_AGG(users.id) @> ARRAY[?]", ids)
    end
    # rubocop:enable CodeReuse/ActiveRecord
  end
end
