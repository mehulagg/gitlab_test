# frozen_string_literal: true

module Banzai
  module Filter
    class FeatureFlagReferenceFilter < IssuableReferenceFilter
      self.reference_type = :operations_feature_flag

      def self.object_name
        @object_name ||= 'operations_feature_flag'
      end

      def self.object_class
        ::Operations::FeatureFlag
      end

      def object_link_title(feature_flag, _matches)
        feature_flag.name
      end

      def url_for_object(feature_flag, project)
        return feature_flag_path(feature_flag, project) if only_path?

        feature_flag_url(feature_flag, project)
      end

      def parent_records(parent, ids)
        parent.operations_feature_flags.where(iid: ids.to_a)
      end

      private

      def feature_flag_path(feature_flag, project)
        Gitlab::Routing.url_helpers.namespace_project_feature_flag_path(
          namespace_id: project.namespace,
          project_id: project,
          iid: feature_flag.iid)
      end

      def feature_flag_url(feature_flag, project)
        Gitlab::Routing.url_helpers.namespace_project_feature_flag_url(
          namespace_id: project.namespace,
          project_id: project,
          iid: feature_flag.iid)
      end
    end
  end
end
