# frozen_string_literal: true

require 'spec_helper'
require 'lib/gitlab/badge/shared/metadata'

describe Gitlab::Badge::Release::Metadata do
  let(:badge) do
    double(project: create(:project), ref: 'feature', job: 'test')
  end

  let(:metadata) { described_class.new(badge) }

  it_behaves_like 'badge metadata'

  describe '#title' do
    it 'returns latest release title' do
      expect(metadata.title).to eq 'latest release'
    end
  end

  describe '#image_url' do
    it 'returns valid url' do
      expect(metadata.image_url).to include 'badges/feature/release.svg'
    end
  end

  describe '#link_url' do
    it 'returns valid link' do
      expect(metadata.link_url).to include 'releases'
    end
  end
end
