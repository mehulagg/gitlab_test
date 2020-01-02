# frozen_string_literal: true

require 'spec_helper'

describe Ci::Metadatable do
  let(:metadatable) { build(:ci_build) }

  describe '#environment_auto_stop_in' do
    subject { metadatable.environment_auto_stop_in = value }

    let(:value) { '1 day' }

    it 'sets environment_auto_stop_in as a metadata' do
      expect(metadatable.environment_auto_stop_in).to be_nil

      subject

      expect(metadatable.environment_auto_stop_in).to eq(value)
    end
  end
end
