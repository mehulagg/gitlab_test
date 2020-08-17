# frozen_string_literal: true

module SkipCallbacks
  def run_callbacks(kind, *args, &block)
    yield(*args) if block_given?
  end
end
