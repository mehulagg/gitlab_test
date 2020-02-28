# frozen_string_literal: true

module EE
  module Search
    module ProjectService
      extend ::Gitlab::Utils::Override
      include ::Search::Elasticsearchable

      override :execute
      def execute
        return super unless use_elasticsearch?

        # We use elastic for default branch only
        if root_ref?
          ::Gitlab::Elastic::ProjectSearchResults.new(
            current_user,
            params[:search],
            project.id,
            repository_ref
          )
        else
          ::Gitlab::ProjectSearchResults.new(
            current_user,
            project,
            params[:search],
            repository_ref
          )
        end
      end

      def repository_ref
        params[:repository_ref]
      end

      def root_ref?
        project.root_ref?(repository_ref)
      end

      def elasticsearchable_scope
        project
      end
    end
  end
end
