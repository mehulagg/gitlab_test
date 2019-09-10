# frozen_string_literal: true
require 'spec_helper'

describe Packages::Conan::CreatePackageFileService do
  let(:package) { create(:conan_package) }

  describe '#execute' do
    context 'with valid params' do
      let(:params) do
        {
          file: Tempfile.new,
          file_name: 'foo.tgz',
          path: '0/export'
        }
      end

      it 'creates a new package file' do
        package_file = described_class.new(package, params).execute

        expect(package_file).to be_valid
        expect(package_file.file_name).to eq('foo.tgz')
        expect(package_file.conan_file_metadatum.path).to eq('0/export')
        expect(package_file.conan_file_metadatum.revision).to eq('0')
      end
    end

    context 'file is missing' do
      let(:params) do
        {
          file_name: 'foo.tgz',
          path: '0/export'
        }
      end

      it 'raises an error' do
        service = described_class.new(package, params)

        expect { service.execute }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
