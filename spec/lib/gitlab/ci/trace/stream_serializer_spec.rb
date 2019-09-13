# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Trace::StreamSerializer do
  let(:serializer) { described_class.new(stream, build) }
  let(:build) { build_stubbed(:ci_build, :running) }
  let(:data) { "hello world" }

  let(:stream) do
    Gitlab::Ci::Trace::Stream.new do
      StringIO.new(data)
    end
  end

  describe '#serialize' do
    subject { serializer.serialize(content_format: content_format, state: nil) }

    shared_examples 'serializes metadata' do
      it 'includes build metadata' do
        expect(subject[:id]).to eq(build.id)
        expect(subject[:status]).to eq('running')
        expect(subject[:complete]).to be_falsey
      end

      it 'includes trace metadata' do
        expect(subject[:offset]).to eq(0)
        expect(subject[:size]).to eq(11)
        expect(subject[:total]).to eq(11)
        expect(subject[:truncated]).to be_falsey
        expect(subject[:state]).not_to be_empty
      end
    end

    context 'when content format is json' do
      let(:content_format) { :json }

      it_behaves_like 'serializes metadata'

      it 'serializes stream lines to json' do
        expect(subject[:lines]).to eq([{ content: [{ text: 'hello world' }], offset: 0 }])
      end
    end

    context 'when content format is html (legacy)' do
      let(:content_format) { :html }

      it_behaves_like 'serializes metadata'

      it 'serializes stream lines to html' do
        expect(subject[:html]).to eq('<span>hello world</span>')
      end
    end
  end
end
