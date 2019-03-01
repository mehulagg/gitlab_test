# frozen_string_literal: true

require 'spec_helper'

describe EE::API::Entities::JobRequest::Port do
  let(:port) { double(external_port: 80, internal_port: 80, insecure: true, name: 'name')}
  let(:entity) { described_class.new(port) }

  subject { entity.as_json }

  it 'returns the external_port' do
    expect(subject[:external_port]).to eq 80
  end

  it 'returns the internal_port' do
    expect(subject[:internal_port]).to eq 80
  end

  it 'returns if the port is insecure' do
    expect(subject[:insecure]).to eq true
  end

  it 'returns the name' do
    expect(subject[:name]).to eq 'name'
  end
end
