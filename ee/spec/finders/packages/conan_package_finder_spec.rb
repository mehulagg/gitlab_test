# frozen_string_literal: true
require 'spec_helper'

describe Packages::ConanPackageFinder do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :public) }

  describe '#api_search' do
    let!(:conan_package) { create(:conan_package, project: project) }
    let!(:conan_package2) { create(:conan_package, project: project) }

    subject { described_class.new(user, query: query).api_search }

    context 'packages that are not visible to user' do
      let!(:non_visible_project) { create(:project, :private) }
      let!(:non_visible_conan_package) { create(:conan_package, project: non_visible_project) }
      let(:query) { "#{conan_package.name.split('/').first[0, 3]}%" }

      it { is_expected.to eq [conan_package, conan_package2] }
    end
  end

  describe '#execute' do
    let(:recipe) { 'my/unfound@package/recipe' }
    let(:project) { create(:project) }

    subject { described_class.new(user, project: project, recipe: recipe).execute }

    context 'no project exists' do
      let(:project) { nil }

      it { is_expected.to be_nil }
    end

    context 'project exists' do
      before do
        project.add_user(user, :developer)
      end

      context 'with packages' do
        let(:package) { create(:conan_package, project: project) }
        let(:recipe) { package.name }

        it { is_expected.to eq package }
      end

      context 'project with no packages' do
        it { is_expected.to be_nil}
      end
    end
  end
end
