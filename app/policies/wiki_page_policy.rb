# frozen_string_literal: true

class WikiPagePolicy < BasePolicy
  delegate :wiki

  rule { can?(:read_wiki) }.enable :read_wiki_page
end
