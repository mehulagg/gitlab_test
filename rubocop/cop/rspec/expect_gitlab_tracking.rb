# frozen_string_literal: true

require 'rack/utils'

module RuboCop
  module Cop
    module RSpec
      # This cops checks for `have_http_status` usages in specs.
      # It also discourages the usage of numeric HTTP status codes in
      # `have_gitlab_http_status`.
      #
      # @example
      #
      # # bad
      # expect(Gitlab::Tracking).to receive(:event)
      #
      # # good
      # expect_snowplow_event(...)
      #
      class ExpectGitlabTracking < RuboCop::Cop::Cop
        def_node_matcher :expect_gitlab_tracking?, <<~PATTERN
          (send
            (send nil? :expect
              (const (const nil? :Gitlab) :Tracking)
            )
            {:to :not_to}
            {
              (
                send nil? :receive (sym :event) ...
              )

              (send
                (send nil? :receive (sym :event)) :with
                ...
              )
            }
            ...
          )
        PATTERN

        def on_send(node)
          if expect_gitlab_tracking?(node)
            add_offense(node, location: :expression, message: 'Do Not Do That')
          end
        end
      end
    end
  end
end
