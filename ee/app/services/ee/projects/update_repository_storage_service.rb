# frozen_string_literal: true

module EE
  module Projects
    module UpdateRepositoryStorageService
      extend ::Gitlab::Utils::Override

      override :mirror_repositories
      def mirror_repositories(new_repository_storage_key)
        result = super

        if project.design_repository.exists?
          result &&= mirror_repository(new_repository_storage_key, type: Gitlab::GlRepository::DESIGN)
        end

        result
      end
    end
  end
end
