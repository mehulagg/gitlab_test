# frozen_string_literal: true

require 'spec_helper'

describe GroupExport, type: :model do
  subject { create(:group_export) }

  describe 'associations' do
    it { is_expected.to belong_to(:group) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:group) }
  end

  describe 'state transitions' do
    context 'state transition: [:none] => [:created]' do
      it 'updates status to created' do
        expect(subject.status_name).to eq(:created)
      end
    end

    context 'state transition: [:any] => [:failed]' do
      subject { create(:group_export, :started) }

      before do
        subject.fail_op!(error: 'Error!')
      end

      it 'updates status to failed' do
        expect(subject.status_name).to eq(:failed)
      end

      it 'updates status_reason' do
        expect(subject.status_reason).to eq({ error: 'Error!' }.to_s)
      end
    end
  end
end
