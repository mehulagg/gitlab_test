# frozen_string_literal: true

require 'spec_helper'

describe Git::Logger do
  let(:merge_request) { create(:merge_request) }
  let(:merge_request_ref) { merge_request.to_reference(full: true) }

  subject do
    Class.new do
      attr_accessor :merge_request

      include Git::Logger

      def initialize(merge_request)
        @merge_request = merge_request
      end
    end
  end

  it 'logs an exception' do
    exception = RuntimeError.new('an error')

    expect(Gitlab::GitLogger).to receive(:error).and_call_original
    expect(Gitlab::ErrorTracking).to receive(:track_exception).with(exception,
      class: nil,
      merge_request: merge_request_ref,
      merge_request_id: merge_request.id,
      message: 'some error',
      save_message_on_model: false).and_call_original

    subject.new(merge_request).log_error(exception: RuntimeError.new('an error'), message: 'some error')
  end

  it 'logs a message' do
    expect(Gitlab::GitLogger).to receive(:error).and_call_original
    expect(Gitlab::ErrorTracking).not_to receive(:track_exception)

    subject.new(merge_request).log_error(exception: nil, message: 'some error')
  end
end
