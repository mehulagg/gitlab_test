# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Config do
  subject { described_class.new(yml) }

  let(:yml) do
    <<-EOS
    sample_job:
      script:
        - echo 'test'
    EOS
  end

  it 'processes the required includes' do
    expect(::Gitlab::Ci::Config::Required::Processor).to receive_message_chain(:new, :perform)

    subject
  end
end
