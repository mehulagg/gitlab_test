# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::AuthorizedKeys do
  include StubENV

  let(:logger) { double('logger').as_null_object }

  subject(:authorized_keys) { described_class.new(logger) }

  describe '#accessible?' do
    subject { authorized_keys.accessible? }

    context 'authorized_keys file exists' do
      before do
        create_authorized_keys_fixture
      end

      after do
        delete_authorized_keys_file
      end

      context 'can open file' do
        it { is_expected.to be_truthy }
      end

      context 'cannot open file' do
        before do
          allow(File).to receive(:open).and_raise(Errno::EACCES)
        end

        it { is_expected.to be_falsey }
      end
    end

    context 'authorized_keys file does not exist' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#create' do
    subject { authorized_keys.create }

    context 'authorized_keys file exists' do
      before do
        create_authorized_keys_fixture
      end

      after do
        delete_authorized_keys_file
      end

      it { is_expected.to be_truthy }
    end

    context 'authorized_keys file does not exist' do
      after do
        delete_authorized_keys_file
      end

      it 'creates authorized_keys file' do
        expect(subject).to be_truthy
        expect(File.exist?(tmp_authorized_keys_path)).to be_truthy
      end
    end

    context 'cannot create file' do
      before do
        allow(File).to receive(:open).and_raise(Errno::EACCES)
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#add_key' do
    let(:id) { 'key-741' }

    subject { authorized_keys.add_key(id, key) }

    context 'authorized_keys file exists' do
      let(:key) { 'ssh-rsa AAAAB3NzaDAxx2E trailing garbage' }

      before do
        create_authorized_keys_fixture
      end

      after do
        delete_authorized_keys_file
      end

      it 'is successful and is logged' do
        expect(logger).to receive(:info).with('Adding key (key-741): ssh-rsa AAAAB3NzaDAxx2E')
        expect(subject).to be_truthy
      end

      it "adds a line at the end of the file and strips trailing garbage" do
        auth_line = "command=\"#{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-741\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaDAxx2E"
        subject

        expect(File.read(tmp_authorized_keys_path)).to eq("existing content\n#{auth_line}\n")
      end

      it 'includes SSL_CERT_DIR if defined in ENV' do
        stub_env('SSL_CERT_DIR', '/tmp/certs')

        auth_line = "command=\"SSL_CERT_DIR=/tmp/certs #{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-741\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaDAxx2E"
        subject

        expect(File.read(tmp_authorized_keys_path)).to eq("existing content\n#{auth_line}\n")
      end
    end

    context 'authorized_keys file does not exist' do
      let(:key) { 'ssh-rsa AAAAB3NzaDAxx2E' }

      before do
        delete_authorized_keys_file
      end

      it 'creates the file' do
        expect(subject).to be_truthy
        expect(File.exist?(tmp_authorized_keys_path)).to be_truthy
      end
    end
  end

  describe '#batch_add_keys' do
    let(:key_id_1) { 'key-123' }
    let(:key_id_2) { 'key-456' }
    let(:keys) do
      [
        double(shell_id: key_id_1, key: 'ssh-dsa ASDFASGADG trailing garbage'),
        double(shell_id: key_id_2, key: 'ssh-rsa GFDGDFSGSDFG')
      ]
    end

    subject { authorized_keys.batch_add_keys(keys) }

    context 'authorized_keys file exists' do
      before do
        create_authorized_keys_fixture
      end

      after do
        delete_authorized_keys_file
      end

      it "adds lines at the end of the file" do
        expect(logger).to receive(:info).with('Adding key (key-123): ssh-dsa ASDFASGADG')
        expect(logger).to receive(:info).with('Adding key (key-456): ssh-rsa GFDGDFSGSDFG')
        expect(subject).to be_truthy

        expect(authorized_keys.key_exists?(key_id_1)).to be_truthy
        expect(authorized_keys.key_exists?(key_id_2)).to be_truthy
      end

      context "invalid key" do
        let(:keys) { [double(shell_id: 'key-123', key: "ssh-rsa A\tSDFA\nSGADG")] }

        it "doesn't add keys" do
          expect(subject).to be_falsey
          expect(File.read(tmp_authorized_keys_path)).to eq("existing content\n")
        end
      end
    end

    context 'authorized_keys file does not exist' do
      before do
        delete_authorized_keys_file
      end

      it 'creates the file' do
        expect(subject).to be_truthy
        expect(File.exist?(tmp_authorized_keys_path)).to be_truthy
      end
    end
  end

  describe '#key_exists?' do
    let(:key_id) { 'key-741' }
    let(:key) { { id: key_id, key: 'ssh-rsa AAAAB3NzaC1yc2E' } }
    let(:other_key) { { id: 'key-742', key: 'ssh-rsa AAAAB3NzaDAxx2E' } }

    subject { authorized_keys.key_exists?(key_id) }

    context 'authorized_keys file exists' do
      before do
        create_authorized_keys_fixture

        authorized_keys.add_key(other_key[:id], other_key[:key])
      end

      after do
        delete_authorized_keys_file
      end

      context 'but the key has not been added' do
        it { is_expected.to be_falsey }
      end

      context 'and the key has been added' do
        let(:stub_ssl_cert_dir_at_create_time) { nil }

        before do
          stub_env('SSL_CERT_DIR', '/tmp/certs') if stub_ssl_cert_dir_at_create_time
          authorized_keys.add_key(key[:id], key[:key])
        end

        shared_examples 'key exists' do |stub_ssl_cert_dir|
          it 'returns true' do
            stub_env('SSL_CERT_DIR', '/tmp/certs') if stub_ssl_cert_dir

            expect(subject).to be_truthy
          end
        end

        include_examples 'key exists', nil

        context 'when a key has been written without SSL_CERT_DIR defined in ENV' do
          let(:stub_ssl_cert_dir_at_create_time) { false }

          include_examples 'key exists', true
          include_examples 'key exists', false
        end

        context 'when a key has been written with SSL_CERT_DIR defined in ENV' do
          let(:stub_ssl_cert_dir_at_create_time) { true }

          include_examples 'key exists', true
          include_examples 'key exists', false
        end
      end
    end

    context 'authorized_keys file does not exist' do
      before do
        delete_authorized_keys_file
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#remove_key' do
    let(:key_id) { 'key-741' }

    subject { authorized_keys.remove_key(key_id) }

    context 'authorized_keys file exists' do
      let(:delete_key) { { id: key_id, key: 'ssh-rsa AAAAB3NzaC1yc2E' } }
      let(:other_key) { { id: 'key-742', key: 'ssh-rsa AAAAB3NzaDAxx2E' } }
      let(:stub_ssl_cert_dir_at_create_time) { nil }

      before do
        create_authorized_keys_fixture

        stub_env('SSL_CERT_DIR', '/tmp/certs') if stub_ssl_cert_dir_at_create_time
        authorized_keys.add_key(other_key[:id], other_key[:key])
        authorized_keys.add_key(delete_key[:id], delete_key[:key])
      end

      after do
        delete_authorized_keys_file
      end

      it 'is successful and is logged' do
        expect(logger).to receive(:info).with('Removing key (key-741)')
        expect(subject).to be_truthy
      end

      shared_examples 'key removal' do |stub_ssl_cert_dir|
        it 'removes the right key' do
          stub_env('SSL_CERT_DIR', '/tmp/certs') if stub_ssl_cert_dir

          expect(subject).to be_truthy
          expect(authorized_keys.key_exists?(key_id)).to be_falsey
        end
      end

      include_examples 'key removal', nil

      context 'when a key has been written without SSL_CERT_DIR defined in ENV' do
        let(:stub_ssl_cert_dir_at_create_time) { false }

        include_examples 'key removal', true
        include_examples 'key removal', false
      end

      context 'when a key has been written with SSL_CERT_DIR defined in ENV' do
        let(:stub_ssl_cert_dir_at_create_time) { true }

        include_examples 'key removal', true
        include_examples 'key removal', false
      end
    end

    context 'authorized_keys file does not exist' do
      before do
        delete_authorized_keys_file
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#clear' do
    subject { authorized_keys.clear }

    context 'authorized_keys file exists' do
      before do
        create_authorized_keys_fixture
      end

      after do
        delete_authorized_keys_file
      end

      it { is_expected.to be_truthy }
    end

    context 'authorized_keys file does not exist' do
      before do
        delete_authorized_keys_file
      end

      it { is_expected.to be_truthy }
    end
  end

  describe '#list_key_ids' do
    subject { authorized_keys.list_key_ids }

    context 'authorized_keys file exists' do
      before do
        create_authorized_keys_fixture(
          existing_content:
            "key-1\tssh-dsa AAA\nkey-2\tssh-rsa BBB\nkey-3\tssh-rsa CCC\nkey-9000\tssh-rsa DDD\n"
        )
      end

      after do
        delete_authorized_keys_file
      end

      it { is_expected.to eq([1, 2, 3, 9000]) }
    end

    context 'authorized_keys file does not exist' do
      before do
        delete_authorized_keys_file
      end

      it { is_expected.to be_empty }
    end
  end

  def create_authorized_keys_fixture(existing_content: 'existing content')
    FileUtils.mkdir_p(File.dirname(tmp_authorized_keys_path))
    File.open(tmp_authorized_keys_path, 'w') { |file| file.puts(existing_content) }
  end

  def delete_authorized_keys_file
    File.delete(tmp_authorized_keys_path) if File.exist?(tmp_authorized_keys_path)
  end

  def tmp_authorized_keys_path
    Gitlab.config.gitlab_shell.authorized_keys_file
  end
end
