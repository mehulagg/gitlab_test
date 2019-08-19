# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Packages::PackageMetadatum, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to(:package) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:package) }

    describe '#metadata' do
      it { is_expected.to allow_value("metadata").for(:metadata) }
    end

    describe '.map_metadatum' do
      subject { described_class.map_metadatum}
    end
  end
end
