# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::Group::Parts::Factory do
  let(:export) { create(:group_export) }
  let(:params) { {} }

  subject { described_class.parts_for(group_part, export, params) }

  describe '.parts_for' do
    context 'when group part is relations' do
      let(:group_part) { :relations }

      it 'returns instance of Parts::Relations' do
        expect(subject).to be_instance_of(Gitlab::ImportExport::Group::Parts::Relations)
      end
    end

    context 'when group part is attributes' do
      let(:group_part) { :attributes }

      it 'returns instance of Parts::Attributes' do
        expect(subject).to be_instance_of(Gitlab::ImportExport::Group::Parts::Attributes)
      end
    end

    context 'when group part is unknown' do
      let(:group_part) { :unknown }

      it 'raises NotImplementedError' do
        expect { subject }.to raise_error(NotImplementedError)
      end
    end
  end
end
