# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Config::Entry::ImageWithPorts do
  let(:entry) { described_class.new(config) }

  include_examples 'CI::Config::Entry::Image validations'

  context 'when configuration is a string' do
    let(:config) { 'ruby:2.2' }

    describe '#ports' do
      it "returns image's ports" do
        expect(entry.ports).to be_nil
      end
    end
  end

  context 'when configuration is a hash' do
    let(:ports) { [{ number: 80, insecure: false, name: 'foobar' }] }
    let(:config) { { name: 'ruby:2.2', entrypoint: %w(/bin/sh run), ports: ports } }

    describe '#ports' do
      it "returns image's ports" do
        expect(entry.ports).to eq ports
      end
    end
  end
end
