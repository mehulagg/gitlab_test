# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Packages::ConanFileMetadatum, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to(:package_file) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:package_file) }

    describe '#revision' do
      it { is_expected.to allow_value("0").for(:revision) }
      it { is_expected.not_to allow_value(nil).for(:revision) }
    end

    describe '#path' do
      it { is_expected.to allow_value("0/export").for(:path) }
      it { is_expected.to allow_value("0/package").for(:path) }
      it { is_expected.not_to allow_value(nil).for(:path) }
    end
  end

  context 'package file identifiers' do
    let(:conan_recipe_file) { create(:conan_package_file, :conan_recipe_file)}
    let(:conan_package_file) { create(:conan_package_file, :conan_package)}

    describe '#package_path?' do
      it 'returns true for package files' do
        expect(conan_package_file.conan_file_metadatum.package_path?).to be true
      end

      it 'returns false for non-package files' do
        expect(conan_recipe_file.conan_file_metadatum.package_path?).to be false
      end
    end

    describe '#recipe_path?' do
      it 'returns true for recipe files' do
        expect(conan_recipe_file.conan_file_metadatum.recipe_path?).to be true
      end

      it 'returns false for non-recipe files' do
        expect(conan_package_file.conan_file_metadatum.recipe_path?).to be false
      end
    end
  end
end
