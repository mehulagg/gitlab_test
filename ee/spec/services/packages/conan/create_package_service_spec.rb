# frozen_string_literal: true
require 'spec_helper'

describe Packages::Conan::CreatePackageService do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  subject { described_class.new(project, user, params) }

  describe '#execute' do
    context 'valid params' do
      let(:version) { '1.0.0' }
      let(:name) { "my-pkg/1.0.0@#{project.full_path.tr('/', '+')}/stable" }
      let(:params) do
        {
          name: name,
          version: '1.0.0'
        }
      end

      it 'creates a new package' do
        package = subject.execute

        expect(package).to be_valid
        expect(package.name).to eq(name)
        expect(package.version).to eq(version)
        expect(package.package_type).to eq('conan')
      end
    end
  end
end
