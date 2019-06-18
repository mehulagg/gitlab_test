# frozen_string_literal: true
require 'spec_helper'

describe Packages::CreateNpmPackageService do
  let(:namespace) {create(:namespace)}
  let(:project) { create(:project, namespace: namespace) }
  let(:user) { create(:user) }
  let(:version) { '1.0.1'.freeze }

  let(:params) do
    JSON.parse(
      fixture_file('npm/payload.json', dir: 'ee')
        .gsub('@root/npm-test', package_name)
        .gsub('1.0.1', version))
      .with_indifferent_access
  end

  shared_examples 'valid package' do
    it 'creates a valid package' do
      package = described_class.new(project, user, params).execute

      expect(package).to be_valid
      expect(package.name).to eq(package_name)
      expect(package.version).to eq(version)
    end
  end

  describe '#execute' do
    context 'scoped package' do
      let(:package_name) { "@#{namespace.path}/my-app".freeze }

      it_behaves_like 'valid package'
    end

    context 'normal package' do
      let(:package_name) { 'my-app'.freeze }

      it 'returns a 400 error' do
        response = described_class.new(project, user, params).execute

        expect(response[:http_status]).to be 400
        expect(response[:message]).to be 'Invalid package name'
      end
    end

    context 'invalid package name' do
      let(:package_name) { "@#{namespace.path}/my-group/my-app".freeze }

      it 'returns a 400 error' do
        response = described_class.new(project, user, params).execute

        expect(response[:http_status]).to be 400
        expect(response[:message]).to be 'Invalid package name'
      end
    end

    context 'package name already exists' do
      let(:alt_project) { create(:project, :public, namespace: namespace) }
      let(:package_name) { "@#{namespace.path}/#{alt_project.name}" }

      it 'returns a 403 error' do
        create(:npm_package,
               project: alt_project,
               name: package_name)

        response = described_class.new(project, user, params).execute

        expect(response[:http_status]).to be 403
        expect(response[:message]).to be 'Package name is already taken.'
      end
    end
  end
end
