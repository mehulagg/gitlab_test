# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::DynamicStore do
  it 'has a current store'
  it '#with_store can set the current store and restore it after'
  it 'falls back to a default store when one is not set'
end
