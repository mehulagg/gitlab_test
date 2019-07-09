# frozen_string_literal: true
require 'spec_helper'

describe Packages::CreatePackageMetadataService do
  let(:package) { create(:npm_package) }
  let(:params) do
    JSON.parse(fixture_file('npm/payload.json', dir: 'ee')).with_indifferent_access
  end

  describe '#execute' do
    context 'when packages are published' do

      it 'creates a metadata binary with the contents of package.json' do
        package_version = params[:versions].keys.first
        package_metadata = params[:versions][package_version].to_json

        service = described_class.new(package, package_metadata).execute
        expect(service.metadata).to eq(package_metadata)
      end
    end
  end
end

