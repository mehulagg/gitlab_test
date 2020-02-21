# frozen_string_literal: true

require 'spec_helper'

describe DesignManagement::DesignV432x230Uploader do
  include CarrierWave::Test::Matchers

  let(:model) { create(:design_action, :with_image_v432x230) }
  let(:upload) { create(:upload, :design_action_image_v432x230_upload, model: model) }

  subject(:uploader) { described_class.new(model, :image_v432x230) }

  it_behaves_like 'builds correct paths',
                  store_dir: %r[uploads/-/system/design_management/action/image_v432x230/],
                  upload_path: %r[uploads/-/system/design_management/action/image_v432x230/],
                  relative_path: %r[uploads/-/system/design_management/action/image_v432x230/],
                  absolute_path: %r[#{CarrierWave.root}/uploads/-/system/design_management/action/image_v432x230/]

  context 'object_store is REMOTE' do
    before do
      stub_uploads_object_storage
    end

    include_context 'with storage', described_class::Store::REMOTE

    it_behaves_like 'builds correct paths',
                    store_dir: %r[design_management/action/image_v432x230/],
                    upload_path: %r[design_management/action/image_v432x230/],
                    relative_path: %r[design_management/action/image_v432x230/]
  end

  describe "#migrate!" do
    before do
      uploader.store!(fixture_file_upload('spec/fixtures/dk.png'))
      stub_uploads_object_storage
    end

    it_behaves_like 'migrates', to_store: described_class::Store::REMOTE
    it_behaves_like 'migrates', from_store: described_class::Store::REMOTE, to_store: described_class::Store::LOCAL
  end

  it 'resizes images', :aggregate_failures do
    image_loader = CarrierWave::Test::Matchers::ImageLoader
    original_file = fixture_file_upload('spec/fixtures/dk.png')
    uploader.store!(original_file)

    expect(
      image_loader.load_image(original_file.tempfile.path)
    ).to have_attributes(
      width: 460,
      height: 322
    )
    expect(
      image_loader.load_image(uploader.file.file)
    ).to have_attributes(
      width: 329,
      height: 230
    )
  end

  context 'uploading a whitelisted file extension' do
    it 'stores the image successfully' do
      fixture_file = fixture_file_upload('spec/fixtures/dk.png')

      expect { uploader.cache!(fixture_file) }.to change { uploader.file }.from(nil).to(kind_of(CarrierWave::SanitizedFile))
    end
  end

  context 'uploading a non-whitelisted file' do
    it 'will deny the upload' do
      fixture_file = fixture_file_upload('spec/fixtures/logo_sample.svg', 'image/svg+xml')

      expect { uploader.cache!(fixture_file) }.to raise_exception(
        CarrierWave::IntegrityError,
        'You are not allowed to upload image/svg+xml files'
      )
    end
  end
end
