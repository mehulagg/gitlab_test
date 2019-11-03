# frozen_string_literal: true

require 'spec_helper'

describe ::Gitlab::Ci::Pipeline::Chain::RemoveUnwantedChatJobs do
  let(:project) { create(:project) }

  let(:pipeline) { double(:pipeline) }

  let(:command) do
    double(:command, project: project, chat_data: { command: 'echo' })
  end

  let(:config) do
    double(:config,
      processor: double(:processor,
        jobs: { echo: double(:job_echo), rspec: double(:job_rspec) }))
  end

  describe '#perform!' do
    subject { described_class.new(pipeline, command, config).perform! }

    it 'removes unwanted jobs for chat pipelines' do
      expect(pipeline).to receive(:chat?).and_return(true)

      subject

      expect(config.processor.jobs.keys).to eq([:echo])
    end

    it 'does not remove any jobs for non chat-pipelines' do
      expect(pipeline).to receive(:chat?).and_return(false)

      subject

      expect(config.processor.jobs.keys).to eq([:echo, :rspec])
    end
  end
end
