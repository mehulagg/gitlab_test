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
    end
  end
end

Ci::Queueing::Params.prepend_if_ee('EE::Ci::Queueing::Params')
