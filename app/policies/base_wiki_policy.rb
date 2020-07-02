# frozen_string_literal: true

class BaseWikiPolicy < BasePolicy
  delegate :container

  overrides :download_code, :push_code

  rule { can?(:reporter_access) }.policy do
    enable :download_code
  end

  rule { can?(:create_wiki) }.policy do
    enable :push_code
  end

  rule { ~can?(:read_wiki) }.policy do
    prevent :download_code
    prevent :push_code
  end
end
