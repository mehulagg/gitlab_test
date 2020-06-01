# frozen_string_literal: true

module Ci
  module Queueing
    class Params
      # instance_type
      # group_type
      # project_type
      attr_accessor :runner_type
      attr_accessor :group_ids
      attr_accessor :project_ids

      # a list of all matching tag names
      attr_accessor :tag_names

      # find untagged builds
      attr_accessor :run_untagged

      # run only ref protected builds
      attr_accessor :only_ref_protected

      def key_params
        [
          [:runner_type, runner_type],
          [:group_ids, group_ids&.sort],
          [:project_ids, project_ids&.sort],
          [:tag_names, tag_names&.sort],
          [:run_untagged, run_untagged],
          [:only_ref_protected, only_ref_protected]
        ]
      end

      def key
        # This is not security solution, but rather a way for us to generate
        # the same unique name for the same parameters
        # The most important here is the performance
        Digest::MD5.hexdigest(key_params.to_json)
      end
    end
  end
end

Ci::Queueing::Params.prepend_if_ee('EE::Ci::Queueing::Params')
