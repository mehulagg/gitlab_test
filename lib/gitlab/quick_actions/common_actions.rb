# frozen_string_literal: true

module Gitlab
  module QuickActions
    module CommonActions
      include Gitlab::QuickActions::Dsl

      # This is a dummy command, so that it appears in the autocomplete commands
      desc 'CC'
      params '@user'
      command :cc
    end
  end
end
