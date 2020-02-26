# frozen_string_literal: true

module EE
  module Gitlab
    module GlRepository
      extend ::Gitlab::Utils::Override
      extend ActiveSupport::Concern

      # @deprecated
      DESIGN = ::Gitlab::GlRepository::RepoType.new(
        name: :design,
        access_checker_class: ::Gitlab::GitAccessDesign,
        repository_resolver: -> (project) { ::Gitlab::Repository::DesignManagement.new(project) },
        suffix: :design
      )

      # @deprecated
      EE_TYPES = {
        DESIGN.name.to_s => DESIGN
      }.freeze

      # @deprecated
      override :types
      def types
        super.merge(EE_TYPES)
      end
    end
  end
end
