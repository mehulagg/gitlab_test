# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Auth::GroupSaml::ActiveSsoState do
  around do |example|
    Gitlab::SessionStore.with_session({}) do
      example.run
    end
  end

  describe '#update_sign_in' do
    it 'updates the current sign in state' do
      new_state = double
      described_class.update_sign_in(1, new_state)

      expect(described_class.dynamic_store[1]).to eq new_state
    end
  end

  describe '#sign_in_state' do
  end

  #describe 'clear_sign_ins'
end
