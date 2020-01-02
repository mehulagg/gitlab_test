# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::AppMultiLogger, :request_store do
  subject { described_class }

  it 'builds a ::Logger object twice' do
    expect(::Logger).to receive(:new).twice.and_call_original

    subject.info('hello world')
  end

  it 'logs info to AppLogger and AppJsonLogger' do
    expect(Gitlab::AppTextLogger).to receive(:build).and_call_original
    expect(Gitlab::AppJsonLogger).to receive(:build).and_call_original

    subject.info('hello world')
  end
end
