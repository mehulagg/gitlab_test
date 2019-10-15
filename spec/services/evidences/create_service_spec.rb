# frozen_string_literal: true

require 'spec_helper'

describe Evidences::CreateService do
  let(:evidence) { build(:evidence, release: create(:release)) }

  subject { described_class.new(evidence) }

  describe '#generate_summary' do
    it 'calls the Evidence serializer' do
      expect_any_instance_of(Evidences::EvidenceSerializer).to receive(:represent).with(evidence)

      subject.generate_summary
    end
  end
end
