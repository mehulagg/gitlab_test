# frozen_string_literal: true

module Storage
  class HashedSnippet
    include Storage::Hashable

    private

    def repository_path_prefix
      '@snippets'
    end
  end
end
