require 'spec_helper'

describe Packages::CreatePackageDependencyService do
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
      let(:package_dependencies) { params[:versions][package_version] }
      let!(:package) { create(:npm_package) }

      subject(:execute) { described_class.new(package, package_dependencies).execute }

      it 'creates package dependencies and package links for a package' do
        execute
        expect(package.package_dependencies[0].name).to eq('express')
        expect(package.package_dependency_links[0].dependency_type).to eq('dependencies')
      end
    end
  end
end
