# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::SessionStore do
  it 'uses stores data under the current thread'
  it '#with_session sets session hash and restores it after'
end
