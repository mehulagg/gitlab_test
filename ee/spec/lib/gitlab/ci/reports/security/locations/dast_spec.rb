# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::Security::Locations::Dast do
  let(:params) do
    {
      hostname: 'my-app.com',
      method_name: 'GET',
      param: 'X-Content-Type-Options',
      path: '/some/path'
    }
  end

  let(:mandatory_params) { %i[path method_name] }
  let(:expected_fingerprint) { Digest::SHA1.hexdigest('/some/path:GET:X-Content-Type-Options') }

  it_behaves_like 'vulnerability location'

  it 'produces a fingerprint for an empty path' do
    location = described_class.new(**params.merge(path: ''))

    expect(location.fingerprint).not_to be_empty
  end

  it 'path querystring should not affect the fingerprint' do
    location_a = described_class.new(**params.merge(path: '/path'))
    location_b = described_class.new(**params.merge(path: '/path?search=term&order=price'))

    expect(location_a.fingerprint).to eq(location_b.fingerprint)
  end

  it 'path fragment should not affect the fingerprint' do
    location_a = described_class.new(**params.merge(path: '/path#page-1'))
    location_b = described_class.new(**params.merge(path: '/path#page-2'))

    expect(location_a.fingerprint).to eq(location_b.fingerprint)
  end

  it 'path ending in slash should not affect the fingerprint' do
    location_a = described_class.new(**params.merge(path: '/path/'))
    location_b = described_class.new(**params.merge(path: '/path'))

    expect(location_a.fingerprint).to eq(location_b.fingerprint)
  end

  it 'can create a fingerprint if path is not a valid URI' do
    location = described_class.new(**params.merge(path: 'not a valid URI'))

    expect(location.fingerprint).not_to be_empty
  end
end
