# frozen_string_literal: true

require 'spec_helper'

describe FaviconUploader do
  let_it_be(:model) { build_stubbed(:user) }
  let_it_be(:uploader) { described_class.new(model, :favicon) }

  context 'upload non-whitelisted file extensions' do
    it 'will deny upload' do
      path = File.join('spec', 'fixtures', 'banana_sample.gif')
      fixture_file = fixture_file_upload(path)
      expect { uploader.cache!(fixture_file) }.to raise_exception(CarrierWave::IntegrityError)
    end
  end
end
