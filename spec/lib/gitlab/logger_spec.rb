# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Logger do
  context '.read_latest' do
    context 'when log file start with dash' do
      let(:log_path) { File.join(Dir.mktmpdir('-logs'), 'file.log') }
      let(:message) { 'foobar' }

      before do
        allow(described_class).to receive(:full_log_path).and_return(log_path)

        described_class.info(message)
      end

      it 'does not raise any error' do
        expect(described_class.read_latest.last).to include(message)
      end
    end
  end
end
