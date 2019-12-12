# frozen_string_literal: true

module Storage
  class HashedProject
    include Storage::Hashable

    delegate :gitlab_shell, to: :container
  end
end
