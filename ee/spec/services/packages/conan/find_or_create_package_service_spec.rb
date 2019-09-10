# frozen_string_literal: true

require 'spec_helper'

describe Packages::Conan::FindOrCreatePackageService do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  subject { described_class.new(project, user, params) }

  describe '#execute' do
    let(:conan_package) { create(:conan_package, project: project) }

    context 'package is found' do
      let(:params) do
        { recipe: conan_package.conan_recipe }
      end
      it 'returns the package' do
        finder_double = double('ConanPackageFinder', execute: conan_package)
        expect(::Packages::ConanPackageFinder).to receive(:new).with(user, recipe: conan_package.conan_recipe, project: project).and_return(finder_double)

        result = subject.execute
        expect(result).to eq conan_package
      end
    end

    context 'no package is found' do
      let(:params) do
        {
          recipe: "foo/bar@#{project.full_path.tr('/', '+')}/buz",
          path: '0/export',
          recipe_path: "foo/bar/#{project.full_path}/buz"
        }
      end

      it 'does not return the package' do
        finder_double = double('ConanPackageFinder', execute: nil)
        service_double = double('CreatePackageService', execute: [])

        expected_params = {
          name: params[:recipe],
          path: params[:path],
          version: params[:recipe_path].split('/')[1]
        }

        expect(::Packages::ConanPackageFinder).to receive(:new).with(user, recipe: params[:recipe], project: project).and_return(finder_double)
        expect(::Packages::Conan::CreatePackageService).to receive(:new).with(project, user, expected_params).and_return(service_double)

        result = subject.execute
        expect(result).to eq []
      end
    end
  end
end
