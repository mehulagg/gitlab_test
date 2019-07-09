# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Packages::PackageMetadatum, type: :model do

  let(:package_json) do
    JSON.parse(fixture_file('npm/payload.json', dir: 'ee')).with_indifferent_access
  end

  describe 'relationships' do
    it { is_expected.to belong_to(:package) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:package) }
    it { is_expected.to validate_length_of(:metadata).is_at_most(10.kilobytes)}

    describe '#metadata' do
      it { is_expected.to allow_value(package_json).for(:metadata) }
      it "should return invsalid when package_json is greater than 6kb" do
        metadata  = create(:package_metadatum, metadata: package_json)
       expect(metadata).not_to be_valid
      end
    end
  end
end
