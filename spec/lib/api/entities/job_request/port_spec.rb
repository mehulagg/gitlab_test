# frozen_string_literal: true

require 'spec_helper'

describe ::API::Entities::JobRequest::Port do
  let(:port) { double(number: 80, insecure: true, name: 'name')}
  let(:entity) { described_class.new(port) }

  subject { entity.as_json }

  it 'returns the port number' do
    expect(subject[:number]).to eq 80
  end

  it 'returns if the port is insecure' do
    expect(subject[:insecure]).to eq true
  end

  it 'returns the name' do
    expect(subject[:name]).to eq 'name'
  end
end
