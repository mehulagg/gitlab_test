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
  end

  describe '#metadata' do
    let(:large_payload_json) { fixture_file('npm/large_payload.json', dir: 'ee') }

    it { is_expected.to allow_value(package_json).for(:metadata) }

    it "is not valid when package_json is greater than 10kb" do
      package_metadata = build(:package_metadatum, metadata: large_payload_json.to_json)
      expect(package_metadata).to be_invalid
    end
  end
end
