# frozen_string_literal: true

module Ci
  module Queueing
    Result = Struct.new(:build, :valid?)
  end
end
