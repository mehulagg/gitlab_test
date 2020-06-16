# frozen_string_literal: true

# Makes api V4 compatible with old project features permissions methods
#
# After migrating issues_enabled merge_requests_enabled builds_enabled snippets_enabled and wiki_enabled
# fields to a new table "project_features", support for the old fields is still needed in the API.
require 'gitlab/utils'

module ee
  module ProjectFeaturesCompatibility
    extend ActiveSupport::Concern

    def requirements_access_level=(value)
      write_feature_attribute_string(:requirements_access_level, value)
    end
  end
end