# frozen_string_literal: true

module Geo
  class WikiVerificationPrimaryService < RepositoryVerificationPrimaryService
    REPO_TYPE = 'wiki'

    private

    def repository
      project.wiki.repository
    end
  end
end
