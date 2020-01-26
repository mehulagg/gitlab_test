module Gitlab
  class Praefect
    class << self
      def virtual?(storage)
        Gitlab.config.repositories.virtual_storages.include?(storage)
      end

      def internal?(storage)
        all_internal_storages.any? { |cluster| cluster.include?(storage) }
      end

      def all_internal_storages
        Gitlab.config.repositories.virtual_storages.values
      end

      def primary_storage_params(virtual_storage)
        primary_name = primary_storage(virtual_storage)
        return unless primary_name

        Gitlab.config.repositories.virtual_storages[virtual_storage][primary_name]
      end

      def internal_storage_params(internal_storage)
        all_internal_storages.each do |internal_nodes|
          internal_nodes.each do |name, params|
            return params if name == internal_storage
          end
        end

        nil
      end

      def primary_storage(virtual_storage)
        Gitlab.config.repositories.virtual_storages[virtual_storage].each do |name, params|
          return name if params['primary']
        end

        nil
      end

      def secondary_storages(virtual_storage)
        all_storages = Gitlab.config.repositories.virtual_storages[virtual_storage].keys

        all_storages - [primary_storage(virtual_storage)]
      end
    end
  end
end
