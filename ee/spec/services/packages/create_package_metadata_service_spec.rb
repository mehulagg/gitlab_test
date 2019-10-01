require 'spec_helper'

describe Packages::CreatePackageMetadataService do
  describe '#execute' do
    let(:namespace) {create(:namespace)}
    let(:project) { create(:project, namespace: namespace) }
    let(:user) { create(:user) }
    let(:version) { '1.0.1'.freeze }
    let(:package_name) { "@#{namespace.path}/my-app".freeze }

    context 'when packages are published' do
      let(:params) do
        JSON.parse(fixture_file('npm/payload.json', dir: 'ee')
                .gsub('@root/npm-test', package_name)
                .gsub('1.0.1', version))
                .with_indifferent_access
      end
      let(:package_version) { params[:versions].keys.first }
      let(:package_metadata) { params[:versions][package_version].to_json }
      let!(:package) { create(:npm_package) }

      subject(:execute) { described_class.new(package, package_metadata).execute }

      it 'creates a metadata binary with the contents of package.json' do
        execute
        expect(package.reload.package_metadatum.metadata).to eq(package_metadata)
      end
    end
  end
end
