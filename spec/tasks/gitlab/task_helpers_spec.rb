require 'spec_helper'

class TestHelpersTest
  include Gitlab::TaskHelpers
end

describe Gitlab::TaskHelpers do
  subject { TestHelpersTest.new }

  let(:repo) { 'https://gitlab.com/gitlab-org/gitlab-test.git' }
  let(:clone_path) { Rails.root.join('tmp/tests/task_helpers_tests').to_s }
  let(:version) { '1.1.0' }
  let(:tag) { 'v1.1.0' }

  describe '#checkout_or_clone_version' do
    before do
      allow(subject).to receive(:run_command!)
    end

    it 'checkout the version and reset to it' do
      expect(subject).to receive(:checkout_version).with(tag, clone_path)

      subject.checkout_or_clone_version(version: version, repo: repo, target_dir: clone_path)
    end

    context 'with a branch version' do
      let(:version) { '=branch_name' }
      let(:branch) { 'branch_name' }

      it 'checkout the version and reset to it with a branch name' do
        expect(subject).to receive(:checkout_version).with(branch, clone_path)

        subject.checkout_or_clone_version(version: version, repo: repo, target_dir: clone_path)
      end
    end

    context "target_dir doesn't exist" do
      it 'clones the repo' do
        expect(subject).to receive(:clone_repo).with(repo, clone_path)

        subject.checkout_or_clone_version(version: version, repo: repo, target_dir: clone_path)
      end
    end

    context 'target_dir exists' do
      before do
        expect(Dir).to receive(:exist?).and_return(true)
      end

      it "doesn't clone the repository" do
        expect(subject).not_to receive(:clone_repo)

        subject.checkout_or_clone_version(version: version, repo: repo, target_dir: clone_path)
      end
    end
  end

  describe '#clone_repo' do
    it 'clones the repo in the target dir' do
      expect(subject)
        .to receive(:run_command!).with(%W[#{Gitlab.config.git.bin_path} clone -- #{repo} #{clone_path}])

      subject.clone_repo(repo, clone_path)
    end
  end

  describe '#checkout_version' do
    it 'clones the repo in the target dir' do
      expect(subject)
        .to receive(:run_command!).with(%W[#{Gitlab.config.git.bin_path} -C #{clone_path} fetch --quiet origin #{tag}])
      expect(subject)
        .to receive(:run_command!).with(%W[#{Gitlab.config.git.bin_path} -C #{clone_path} checkout -f --quiet FETCH_HEAD --])

      subject.checkout_version(tag, clone_path)
    end
  end

  describe '#run_command' do
    it 'runs command and return the output' do
      expect(subject.run_command(%w(echo it works!))).to eq("it works!\n")
    end

    it 'returns empty string when command doesnt exist' do
      expect(subject.run_command(%w(nonexistentcommand with arguments))).to eq('')
    end
  end

  describe '#run_command!' do
    it 'runs command and return the output' do
      expect(subject.run_command!(%w(echo it works!))).to eq("it works!\n")
    end

    it 'returns and exception when command exit with non zero code' do
      expect { subject.run_command!(['bash', '-c', 'exit 1']) }.to raise_error Gitlab::TaskFailedError
    end
  end

  shared_examples 'system command' do
    it 'memoizes command' do
      expect(Gitlab::Utils).to receive(:which).once.and_return('foo')

      2.times { command }
    end

    it 'returns nil if no binary found' do
      allow(Gitlab::Utils).to receive(:which).with(anything).and_return(nil)

      expect(command).to be_nil
    end
  end

  describe '#make_cmd' do
    let(:make_path) { '/usr/bin/make' }
    let(:gmake_path) { '/usr/bin/gmake' }

    before do
      allow(Gitlab::Utils).to receive(:which).with('make').and_return(make_path)
    end

    context 'when gmake is installed' do
      before do
        allow(Gitlab::Utils).to receive(:which).with('gmake').and_return(gmake_path)
      end

      it 'returns the gmake path' do
        expect(subject.make_cmd).to eq gmake_path
      end
    end

    context 'when gmake is not installed' do
      before do
        allow(Gitlab::Utils).to receive(:which).with('gmake').and_return(nil)
      end

      it 'returns the make path' do
        expect(subject.make_cmd).to eq make_path
      end
    end

    it_behaves_like 'system command' do
      let(:command) { subject.make_cmd }
    end
  end

  describe '#tar_cmd' do
    let(:tar_path) { '/usr/bin/tar' }
    let(:gtar_path) { '/usr/bin/gtar' }

    before do
      allow(Gitlab::Utils).to receive(:which).with('tar').and_return(tar_path)
    end

    context 'when gtar is installed' do
      before do
        allow(Gitlab::Utils).to receive(:which).with('gtar').and_return(gtar_path)
      end

      it 'returns the gtar path' do
        expect(subject.tar_cmd).to eq gtar_path
      end
    end

    context 'when gtar is not installed' do
      before do
        allow(Gitlab::Utils).to receive(:which).with('gtar').and_return(nil)
      end

      it 'returns the tar path' do
        expect(subject.tar_cmd).to eq tar_path
      end
    end

    it_behaves_like 'system command' do
      let(:command) { subject.tar_cmd }
    end
  end
end
