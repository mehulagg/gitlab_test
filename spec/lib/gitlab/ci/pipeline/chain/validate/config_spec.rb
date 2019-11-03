# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Pipeline::Chain::Validate::Config do
  set(:project) { create(:project, :repository) }
  set(:user) { create(:user) }

  let(:pipeline) { build(:ci_pipeline, project: project) }

  let(:command) do
    Gitlab::Ci::Pipeline::Chain::Command.new(
      project: project,
      current_user: user,
      save_incompleted: true)
  end

  let(:yaml) { Gitlab::Ci::Yaml.new(project: project, sha: project.repository.commit.id) }

  let(:step) { described_class.new(pipeline, command, yaml) }

  subject { step.perform! }

  before do
    stub_ci_pipeline_yaml_file(config)
  end

  context 'when project has no YAML configuration' do
    let(:config) { nil }

    it 'appends errors about missing configuration' do
      subject

      expect(pipeline.errors.to_a)
        .to include 'Missing .gitlab-ci.yml file'
    end

    it 'breaks the chain' do
      subject

      expect(step.break?).to be true
    end
  end

  context 'when YAML configuration contains errors' do
    let(:config) { 'invalid YAML' }

    it 'appends errors about YAML errors' do
      subject

      expect(pipeline.errors.to_a)
        .to include 'Invalid configuration format'
    end

    it 'breaks the chain' do
      subject

      expect(step.break?).to be true
    end

    context 'when saving incomplete pipeline is allowed' do
      let(:command) do
        double('command', project: project,
                          current_user: user,
                          save_incompleted: true)
      end

      it 'fails the pipeline' do
        subject

        expect(pipeline.reload).to be_failed
      end

      it 'sets a config error failure reason' do
        subject

        expect(pipeline.reload.config_error?).to eq true
      end
    end

    context 'when saving incomplete pipeline is not allowed' do
      let(:command) do
        double('command', project: project,
                          current_user: user,
                          save_incompleted: false)
      end

      it 'does not drop pipeline' do
        subject

        expect(pipeline).not_to be_failed
        expect(pipeline).not_to be_persisted
      end
    end
  end

  context 'when pipeline contains configuration validation errors' do
    let(:config) do
      YAML.dump({
        rspec: {
          before_script: 10,
          script: 'ls -al'
        }
      })
    end

    it 'appends configuration validation errors to pipeline errors' do
      subject

      expect(pipeline.errors.to_a)
        .to include "jobs:rspec:before_script config should be an array containing strings and arrays of strings"
    end

    it 'breaks the chain' do
      subject

      expect(step.break?).to be true
    end
  end

  context 'when pipeline is correct and complete' do
    let(:config) do
      YAML.dump({
        rspec: { script: 'echo' }
      })
    end

    it 'does not invalidate the pipeline' do
      subject

      expect(pipeline).to be_valid
    end

    it 'sets a valid config source' do
      subject

      expect(pipeline.repository_source?).to be true
    end

    it 'does not break the chain' do
      subject

      expect(step.break?).to be false
    end
  end

  context 'when pipeline source is merge request' do
    let(:pipeline) do
      build(:ci_pipeline, source: :merge_request_event, project: project)
    end

    context "when config contains 'merge_requests' keyword" do
      let(:config) do
        YAML.dump({ rspec: { script: 'echo', only: ['merge_requests'] } })
      end

      it 'does not break the chain' do
        subject

        expect(step).not_to be_break
      end
    end

    context "when config contains 'merge_request' keyword" do
      let(:config) do
        YAML.dump({ rspec: { script: 'echo', only: ['merge_request'] } })
      end

      it 'does not break the chain' do
        subject

        expect(step).not_to be_break
      end
    end
  end
end
