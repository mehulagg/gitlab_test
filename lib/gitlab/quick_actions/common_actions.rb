# frozen_string_literal: true

module Gitlab
  module QuickActions
    module CommonActions
      include Gitlab::QuickActions::Dsl

      # This is a dummy command, so that it appears in the autocomplete commands
      command :cc do
        noop
        desc 'CC'
        params '@user'
      end
    end
  end
end
