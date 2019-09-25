describe Gitlab::QA::Component::Specs do
  let(:docker_command) { spy('docker command') }
  let(:suite) { spy('suite') }

  before do
    stub_const('Gitlab::QA::Docker::Command', docker_command)
  end

  describe '#perform' do
    it 'bind-mounts a docker socket' do
      described_class.perform do |specs|
        specs.suite = suite
        specs.release = spy('release')
      end

      expect(docker_command).to have_received(:volume)
        .with('/var/run/docker.sock', '/var/run/docker.sock')
    end

    it 'bind-mounds volume with screenshots in an appropriate directory' do
      allow(SecureRandom).to receive(:hex).and_return('def456')
      allow(Gitlab::QA::Runtime::Env)
        .to receive(:host_artifacts_dir)
        .and_return('/tmp/gitlab-qa/gitlab-qa-run-2018-07-11-10-00-00-abc123')

      described_class.perform do |specs|
        specs.suite = suite
        specs.release = double('release', edition: :ce, project_name: 'gitlab-ce', qa_image: 'gitlab-ce-qa', qa_tag: 'latest')
      end

      expect(docker_command).to have_received(:volume)
        .with('/var/run/docker.sock', '/var/run/docker.sock')
      expect(docker_command).to have_received(:volume)
        .with('/tmp/gitlab-qa/gitlab-qa-run-2018-07-11-10-00-00-abc123/gitlab-ce-qa-def456', File.join(Gitlab::QA::Docker::Volumes::QA_CONTAINER_WORKDIR, 'tmp'))
    end

    describe 'Docker::Engine#run arguments' do
      let(:docker_engine) { spy('docker engine') }

      before do
        stub_const('Gitlab::QA::Docker::Engine', docker_engine)
      end

      it 'accepts a GitLab image' do
        described_class.perform do |specs|
          specs.suite = suite
          specs.release = Gitlab::QA::Release.new('gitlab/gitlab-ce:foobar')
        end

        expect(docker_engine).to have_received(:run)
          .with('gitlab/gitlab-ce-qa', 'foobar', suite)
      end

      it 'accepts a GitLab QA image' do
        described_class.perform do |specs|
          specs.suite = suite
          specs.release = Gitlab::QA::Release.new('gitlab/gitlab-ce-qa:foobar')
        end

        expect(docker_engine).to have_received(:run)
          .with('gitlab/gitlab-ce-qa', 'foobar', suite)
      end
    end
  end
end
