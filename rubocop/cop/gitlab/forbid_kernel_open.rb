# frozen_string_literal: true

module RuboCop
  module Cop
    module Gitlab
      # This cop is a more restrictive version of the `Security/Open`.
      #
      # The cop `Security/Open` will behave as the following:
      #   # Bad
      #   # open(foo)
      #   # open("|foo #{bar}")
      #
      #   # Good
      #   # open("foo")
      #   # open("|foo")
      #   # open("foo #{bar}")
      #   # Kernel.open("foo")
      #   # Kernel.open("|foo")
      #   # Kernel.open("foo#{bar}")
      #   # Kernel.open("|foo #{bar}")
      #   # Kernel.open(foo)
      #
      # That behavior has several security implications (besides
      # of the point of not forbidding the same use cases when using `Kernel`)
      #
      # In this cop we forbid any use of `open` or `Kernel.open`. It would
      # be better to use `File.open`, `IO.popen` or `Gitlab::HTTP` explicitly.
      #
      # @example
      #   # Bad
      #   # open(foo)
      #   # open("|foo #{bar}")
      #   # open("|foo")
      #   # open("foo #{bar}")
      #   # Kernel.open("|foo")
      #   # Kernel.open("foo#{bar}")
      #   # Kernel.open("|foo #{bar}")
      #   # Kernel.open(foo)

      class ForbidKernelOpen < RuboCop::Cop::Cop
        MSG = 'The use of `Kernel.open` is a serious security risk.'

        def_node_matcher :open_call?, <<~PATTERN
          (send nil? :open (...))
        PATTERN

        def_node_matcher :kernel_open_call?, <<~PATTERN
          (send (const nil? :Kernel) :open ...)
        PATTERN

        def on_send(node)
          if open_call?(node) || kernel_open_call?(node)
            add_offense(node, location: :selector)
          end
        end
      end
    end
  end
end
