# frozen_string_literal: true

require 'spec_helper'

describe Evidences::CreateService do
  let!(:release) { create(:release) }

  subject { described_class.new(release) }

  describe '#execute' do
    context 'when a release is not passed in' do
      it 'raises an error' do
        expect { described_class.new(nil).execute }.to raise_error(StandardError, "Release is empty")
      end
    end

    context 'when a release is passed in' do
      it 'creates a new Evidence object' do
        expect { subject.execute }.to change(Evidence, :count).by(1)
      end

      it 'creates an Evidence linked to the provided release, with a summary' do
        subject.execute
        evidence = Evidence.last

        expect(evidence.release).to eq(release)
        expect(evidence.summary).to be_present
      end
    end
  end
end
