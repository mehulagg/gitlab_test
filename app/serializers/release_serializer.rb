# frozen_string_literal: true

class ReleaseSerializer < BaseSerializer
  include WithPagination

  entity API::Entities::Release
end
