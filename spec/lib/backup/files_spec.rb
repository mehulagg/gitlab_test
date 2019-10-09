# frozen_string_literal: true

require 'spec_helper'

describe Backup::Files do
  let(:progress) { StringIO.new }
  let!(:project) { create(:project) }
  let(:app_files_dir) { '/var/gitlab-registry' }
  let(:name) { 'registry' }

  subject { described_class.new(name, app_files_dir) }

  before do
    allow(progress).to receive(:puts)
    allow(progress).to receive(:print)
    allow(FileUtils).to receive(:mkdir_p).and_return(true)
    allow(FileUtils).to receive(:mv).and_return(true)
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:realpath).with(app_files_dir).and_return(app_files_dir)
    allow(File).to receive(:realpath).with("#{app_files_dir}/..").and_return("/var")

    allow_any_instance_of(String).to receive(:color) do |string, _color|
      string
    end

    allow_any_instance_of(described_class).to receive(:progress).and_return(progress)
  end

  describe '#dump' do
    describe 'when gtar and tar are not available' do
      it 'raises error' do
        # avoid writing task output to spec progress
        allow($stderr).to receive :write
        allow(subject).to receive(:tar).and_return(nil)

        expect { subject.dump }.to raise_error /Couldn't find a 'tar' binary/
      end
    end
  end

  describe '#restore' do
    let(:timestamp) { Time.utc(2017, 3, 22) }

    around do |example|
      Timecop.freeze(timestamp) { example.run }
    end

    describe 'when gtar and tar are not available' do
      it 'raises error' do
        # avoid writing task output to spec progress
        allow($stderr).to receive :write
        allow(subject).to receive(:tar).and_return(nil)

        expect { subject.restore }.to raise_error /Couldn't find a 'tar' binary/
      end
    end

    describe 'folders with permission' do
      before do
        allow(subject).to receive(:run_pipeline!).and_return(true)
        allow(subject).to receive(:backup_existing_files).and_return(true)
        allow(Dir).to receive(:glob).with("#{app_files_dir}/*", File::FNM_DOTMATCH).and_return(["#{app_files_dir}/.", "#{app_files_dir}/..", "#{app_files_dir}/sample1"])
      end

      it 'moves all necessary files' do
        allow(subject).to receive(:backup_existing_files).and_call_original
        expect(FileUtils).to receive(:mv).with(["#{app_files_dir}/sample1"], File.join(Gitlab.config.backup.path, "tmp", "#{name}.#{Time.now.to_i}"))
        subject.restore
      end

      it 'raises no errors' do
        expect { subject.restore }.not_to raise_error
      end

      it 'calls tar command with unlink' do
        allow(subject).to receive(:tar).and_return('blabla-tar')

        expect(subject).to receive(:run_pipeline!).with([%w(gzip -cd), %W(blabla-tar --unlink-first --recursive-unlink -C #{app_files_dir} -xf -)], any_args)
        subject.restore
      end
    end

    describe 'folders without permissions' do
      before do
        allow(FileUtils).to receive(:mv).and_raise(Errno::EACCES)
        allow(subject).to receive(:run_pipeline!).and_return(true)
      end

      it 'shows error message' do
        expect(subject).to receive(:access_denied_error).with(app_files_dir)
        subject.restore
      end
    end

    describe 'folders that are a mountpoint' do
      before do
        allow(FileUtils).to receive(:mv).and_raise(Errno::EBUSY)
        allow(subject).to receive(:run_pipeline!).and_return(true)
      end

      it 'shows error message' do
        expect(subject).to receive(:resource_busy_error).with(app_files_dir)
                             .and_call_original

        expect { subject.restore }.to raise_error(/is a mountpoint/)
      end
    end
  end
end
