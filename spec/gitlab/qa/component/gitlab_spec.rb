describe Gitlab::QA::Component::Gitlab do
  let(:full_ce_address) { 'registry.gitlab.com/foo/gitlab/gitlab-ce' }
  let(:full_ce_address_with_complex_tag) { "#{full_ce_address}:omnibus-7263a2" }

  describe '#omnibus_config=' do
    context 'when set' do
      before do
        subject.omnibus_config = '# Be configured'
      end

      it 'updates environment variables' do
        expect(subject.environment['GITLAB_OMNIBUS_CONFIG'])
          .to eq('# Be configured')
      end
    end
  end

  describe '#release' do
    context 'with no release' do
      it 'defaults to CE' do
        expect(subject.release.to_s).to eq 'gitlab/gitlab-ce:nightly'
      end
    end
  end

  describe '#release=' do
    before do
      subject.release = release
    end

    context 'when release is a Release object' do
      let(:release) { create_release('CE') }

      it 'returns a correct release' do
        expect(subject.release.to_s).to eq 'gitlab/gitlab-ce:nightly'
      end
    end

    context 'when release is a string' do
      context 'with a simple tag' do
        let(:release) { full_ce_address_with_complex_tag }

        it 'returns a correct release' do
          expect(subject.release.to_s).to eq full_ce_address_with_complex_tag
        end
      end
    end
  end

  describe '#name' do
    before do
      subject.release = create_release('EE')
    end

    it 'returns a unique name' do
      expect(subject.name).to match(/\Agitlab-ee-(\w+){8}\z/)
    end
  end

  describe '#hostname' do
    it { expect(subject.hostname).to match(/\Agitlab-ce-(\w+){8}\.\z/) }

    context 'with a network' do
      before do
        subject.network = 'local'
      end

      it 'returns a valid hostname' do
        expect(subject.hostname).to match(/\Agitlab-ce-(\w+){8}\.local\z/)
      end
    end
  end

  describe '#address' do
    context 'with a network' do
      before do
        subject.network = 'local'
      end

      it 'returns a HTTP address' do
        expect(subject.address)
          .to match(%r{http://gitlab-ce-(\w+){8}\.local\z})
      end
    end
  end

  describe '#start' do
    let(:docker) { spy('docker command') }

    before do
      stub_const('Gitlab::QA::Docker::Command', docker)

      allow(subject).to receive(:ensure_configured!)
    end

    it 'runs a docker command' do
      subject.start

      expect(docker).to have_received(:execute!)
    end

    it 'should dynamically bind HTTP port' do
      subject.start

      expect(docker).to have_received(:<<).with('-d -p 80')
    end

    it 'should specify the name' do
      subject.start

      expect(docker).to have_received(:<<)
        .with("--name #{subject.name}")
    end

    it 'should specify the hostname' do
      subject.start

      expect(docker).to have_received(:<<)
        .with("--hostname #{subject.hostname}")
    end

    it 'bind-mounds volume with logs in an appropriate directory' do
      allow(Gitlab::QA::Runtime::Env)
        .to receive(:host_artifacts_dir)
        .and_return('/tmp/gitlab-qa/gitlab-qa-run-2018-07-11-10-00-00-abc123')

      subject.name = 'my-gitlab'

      subject.start

      expect(docker).to have_received(:volume)
        .with('/tmp/gitlab-qa/gitlab-qa-run-2018-07-11-10-00-00-abc123/my-gitlab/logs', '/var/log/gitlab', 'Z')
    end

    context 'with a network' do
      before do
        subject.network = 'testing-network'
      end

      it 'should specify the network' do
        subject.start

        expect(docker).to have_received(:<<)
          .with('--net testing-network')
      end
    end

    context 'with volumes' do
      before do
        subject.volumes = { '/from' => '/to' }
      end

      it 'adds --volume switches to the command' do
        subject.start

        expect(docker).to have_received(:volume)
          .with('/from', '/to', 'Z')
      end
    end

    context 'with environment' do
      before do
        subject.environment = { 'TEST' => 'some value' }
      end

      it 'adds environment variables to the command' do
        subject.start

        expect(docker).to have_received(:env)
          .with('TEST', 'some value')
      end
    end

    context 'with network_alias' do
      before do
        subject.add_network_alias('lolcathost')
      end

      it 'adds --network-alias switches to the command' do
        subject.start

        expect(docker).to have_received(:<<)
          .with('--network-alias lolcathost')
      end
    end
  end

  def create_release(release)
    Gitlab::QA::Release.new(release)
  end
end
