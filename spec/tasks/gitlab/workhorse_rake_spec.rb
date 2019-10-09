require 'rake_helper'

describe 'gitlab:workhorse namespace rake task' do
  before :all do
    Rake.application.rake_require 'tasks/gitlab/workhorse'
  end

  describe 'install' do
    let(:repo) { 'https://gitlab.com/gitlab-org/gitlab-workhorse.git' }
    let(:clone_path) { Rails.root.join('tmp/tests/gitlab-workhorse').to_s }
    let(:version) { File.read(Rails.root.join(Gitlab::Workhorse::VERSION_FILE)).chomp }

    subject { run_rake_task('gitlab:workhorse:install', clone_path) }

    context 'no dir given' do
      it 'aborts and display a help message' do
        # avoid writing task output to spec progress
        allow($stderr).to receive :write

        expect { run_rake_task('gitlab:workhorse:install') }.to raise_error /Please specify the directory where you want to install gitlab-workhorse/
      end
    end

    context 'when an underlying Git command fail' do
      it 'aborts and display a help message' do
        expect(main_object)
          .to receive(:checkout_or_clone_version).and_raise 'Git error'

        expect { subject }.to raise_error 'Git error'
      end
    end

    describe 'checkout or clone' do
      before do
        expect(Dir).to receive(:chdir).with(clone_path)
      end

      it 'calls checkout_or_clone_version with the right arguments' do
        expect(main_object)
          .to receive(:checkout_or_clone_version).with(version: version, repo: repo, target_dir: clone_path)

        subject
      end
    end

    describe 'gmake/make' do
      context 'when gmake and make are not available' do
        it 'aborts and display a help message' do
          # avoid writing task output to spec progress
          allow($stderr).to receive :write
          allow(main_object).to receive(:make_cmd).and_return(nil)

          expect { subject }.to raise_error /Couldn't find a 'make' binary/
        end
      end

      context 'when gmake or make available' do
        before do
          FileUtils.mkdir_p(clone_path)
          expect(Dir).to receive(:chdir).with(clone_path).and_call_original
        end

        shared_examples 'command available' do
          before do
            expect(main_object).to receive(:checkout_or_clone_version)
            allow(main_object).to receive(:run_command!).with([cmd]).and_return(true)
          end

          it 'calls command in the gitlab-workhorse directory' do
            allow(main_object).to receive(:make_cmd).and_return(cmd)
            expect(main_object).to receive(:run_command!).with([cmd]).and_return(true)

            subject
          end
        end

        context 'gmake is available' do
          let(:cmd) { '/usr/bin/gmake' }

          it_behaves_like 'command available'
        end

        context 'gmake is not available' do
          let(:cmd) { '/usr/bin/make' }

          it_behaves_like 'command available'
        end
      end
    end
  end
end
