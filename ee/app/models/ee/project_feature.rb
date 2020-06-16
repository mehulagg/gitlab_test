# frozen_string_literal: true

module EE
  module ProjectFeature
    extend ActiveSupport::Concern

    default_value_for :requirements_access_level,      value: ENABLED, allows_nil: false

    prepended do
      # Ensure changes to project visibility settings go to elasticsearch
      after_commit on: :update do
        project.maintain_elasticsearch_update if project.maintaining_elasticsearch?
      end
    end
  end
end
