# frozen_string_literal: true

module EE
  module Ci
    module Stage
      extend ActiveSupport::Concern

      prepended do
        has_many :downstream_bridges, class_name: '::Ci::Bridges::DownstreamBridge'
        has_many :upstream_bridges, class_name: '::Ci::Bridges::UpstreamBridge'
      end
    end
  end
end
