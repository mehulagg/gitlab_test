# frozen_string_literal: true

describe Gitlab::QA::Report::ResultsInIssues do
  it 'requires a token and input files' do
    expect { subject }.to raise_error(ArgumentError, "missing keywords: token, input_files")
  end

  describe '#invoke!' do
    let(:project) { 'valid-project' }
    let(:test_file_full) { 'qa/specs/features/browser_ui/stage/test_spec.rb' }
    let(:test_file_partial) { 'browser_ui/stage/test_spec.rb' }

    it 'checks that a project was provided' do
      subject = described_class.new(token: 'token', input_files: 'file')

      expect { subject.invoke! }
        .to output(%r{Please provide a valid project ID or path with the `-p/--project` option!}).to_stderr
        .and raise_error(SystemExit)
    end

    it 'checks that input files exist' do
      subject = described_class.new(token: 'token', input_files: 'no-file', project: project)

      expect { subject.invoke! }
        .to output(/Please provide valid JUnit report files. No files were found matching `no-file`/).to_stderr
        .and raise_error(SystemExit)
    end

    context 'when validating user permissions' do
      subject { described_class.new(token: 'token', input_files: 'file', project: project) }

      before do
        allow(subject).to receive(:assert_input_files!)
        allow(::Gitlab).to receive(:user).and_return(Struct.new(:id).new(0))

        Gitlab.configure do |config|
          config.endpoint = 'api'
          config.private_token = 'token'
        end
      end

      it 'checks that the user has at least Maintainer access to the project' do
        expect(::Gitlab).to receive(:team_member).with(project, 0).and_return(Struct.new(:access_level).new(10))

        expect { subject.invoke! }
          .to output("You must have at least Maintainer access to the project to use this feature.\n").to_stderr
          .and raise_error(SystemExit)
      end

      it 'checks that the user is a member of the project' do
        stub_const("Gitlab::Error::NotFound", RuntimeError)

        expect(::Gitlab).to receive(:team_member).with(project, 0).and_raise(Gitlab::Error::NotFound)

        expect { subject.invoke! }
          .to output("You must have at least Maintainer access to the project to use this feature.\n").to_stderr
          .and raise_error(SystemExit)
      end
    end

    context 'with valid input' do
      let(:gitlab_client_config) { double('GitLab client config') }
      let(:test_xml) { %(<testcase name="test-name" file="#{test_file_full}"/>) }

      subject { described_class.new(token: 'token', input_files: 'files', project: project) }

      before do
        allow(subject).to receive(:assert_input_files!)
        allow(subject).to receive(:assert_user_permission!)
        allow(::Dir).to receive(:glob).and_return(['file'])
        allow(::File).to receive(:open).with('file').and_return(test_xml)
      end

      context 'when the GitLab client is configured' do
        before do
          allow(subject).to receive(:report_test)
          allow(::Gitlab).to receive(:configure).and_yield(gitlab_client_config)
          allow(gitlab_client_config).to receive(:endpoint=)
          allow(gitlab_client_config).to receive(:private_token=)
        end

        it 'passes the token to the GitLab client' do
          expect(gitlab_client_config).to receive(:private_token=).with('token')

          expect { subject.invoke! }.to output.to_stdout
        end

        it 'uses the default base API URL' do
          expect(gitlab_client_config).to receive(:endpoint=).with('https://gitlab.com/api/v4')

          expect { subject.invoke! }.to output.to_stdout
        end

        context 'when the base API URL is specified as an environment variable' do
          around do |example|
            ClimateControl.modify(GITLAB_API_BASE: 'http://another.gitlab.url') { example.run }
          end

          it 'uses the specified URL' do
            expect(gitlab_client_config).to receive(:endpoint=).with('http://another.gitlab.url')

            expect { subject.invoke! }.to output.to_stdout
          end
        end
      end

      context 'when an issue exists for a given test' do
        before do
          Gitlab.configure do |config|
            config.endpoint = 'api'
            config.private_token = 'token'
          end
        end

        it 'finds the issue via the test file and name and updates the issue' do
          issue = Struct.new(:web_url, :state, :title).new('http://existing-issue.url', 'opened', "#{test_file_partial} | test-name ")
          search_response = Struct.new(:auto_paginate).new([issue])

          expect(::Gitlab).to receive(:issues)
            .with(anything, { search: %("#{test_file_full}" "test-name") })
            .and_return(search_response)
          expect(subject).to receive(:update_labels)
          expect(subject).to receive(:note_status)

          expect { subject.invoke! }.to output.to_stdout
        end

        context 'when the test name makes the title longer than the maximum 255 character' do
          let(:long_test_name) { 'x' * 255 }
          let(:name_truncated_to_fit_title) { 'x' * 220 }
          let(:test_xml) { %(<testcase name="#{long_test_name}" file="#{test_file_full}"/>) }

          it 'finds the issue with a truncated title' do
            issue = Struct.new(:web_url, :state, :title).new('http://existing-issue.url', 'opened', "#{test_file_partial} | #{name_truncated_to_fit_title}...")
            search_response = Struct.new(:auto_paginate).new([issue])

            expect(::Gitlab).to receive(:issues)
              .with(anything, { search: %("#{test_file_full}" "#{long_test_name}") })
              .and_return(search_response)
            expect(subject).to receive(:update_labels)
            expect(subject).to receive(:note_status)

            expect { subject.invoke! }.to output.to_stdout
          end
        end
      end

      context 'when an issue does not exist for a given test' do
        before do
          Gitlab.configure do |config|
            config.endpoint = 'api'
            config.private_token = 'token'
          end

          allow(subject).to receive(:find_issue).and_return(nil)
          allow(subject).to receive(:update_labels)
          allow(subject).to receive(:note_status)
        end

        let(:new_issue) { Struct.new(:web_url).new('http://new-issue.url') }

        it 'creates a new issue' do
          expect(subject).to receive(:create_issue).and_return(new_issue)

          expect { subject.invoke! }
            .to output(%r{Created new issue: http://new-issue.url\n.*Issue updated}).to_stdout
        end

        context 'when creating a new issue' do
          it 'creates the issue in the provided project' do
            expect(::Gitlab).to receive(:create_issue).with(project, anything, anything).and_return(new_issue)

            expect { subject.invoke! }.to output.to_stdout
          end

          it 'includes the test name and file in the issue title' do
            expect(::Gitlab).to receive(:create_issue).with(anything, "#{test_file_partial} | test-name", anything).and_return(new_issue)

            expect { subject.invoke! }.to output.to_stdout
          end

          it 'includes the test name and file in the issue description' do
            expect(::Gitlab).to receive(:create_issue)
              .with(anything, anything, hash_including(description: "### Full description\n\ntest-name\n\n### File path\n\n#{test_file_full}"))
              .and_return(new_issue)

            expect { subject.invoke! }.to output.to_stdout
          end

          it 'applys the ~status::automated label' do
            expect(::Gitlab).to receive(:create_issue)
              .with(anything, anything, hash_including(labels: 'status::automated'))
              .and_return(new_issue)

            expect { subject.invoke! }.to output.to_stdout
          end

          context 'with EE tests' do
            let(:test_file_full) { 'qa/specs/features/ee/browser_ui/stage/test_spec.rb' }
            let(:new_issue) { Struct.new(:web_url, :labels, :iid).new('http://existing-issue.url', [], 0) }

            it 'applies the ~"Enterprise Edition" label' do
              ClimateControl.modify(CI_PROJECT_NAME: 'staging') do
                allow(subject).to receive(:update_labels).and_call_original
                allow(::Gitlab).to receive(:create_issue).and_return(new_issue)

                expect(::Gitlab).to receive(:edit_issue).with(anything, anything, hash_including(labels: %w[staging::passed Enterprise\ Edition]))

                expect { subject.invoke! }.to output.to_stdout
              end
            end

            it 'removes ee from the path in the title but not the description' do
              expect(::Gitlab).to receive(:create_issue)
                .with(anything,
                      "browser_ui/stage/test_spec.rb | test-name",
                      hash_including(description: "### Full description\n\ntest-name\n\n### File path\n\n#{test_file_full}"))
                .and_return(new_issue)

              expect { subject.invoke! }.to output.to_stdout
            end
          end
        end
      end

      context 'with an existing or new issue' do
        let(:labels) { [] }
        let(:issue) { Struct.new(:web_url, :labels, :iid).new('http://existing-issue.url', labels, 0) }

        before do
          Gitlab.configure do |config|
            config.endpoint = 'api'
            config.private_token = 'token'
          end

          allow(subject).to receive(:find_issue).and_return(issue)
          allow(subject).to receive(:note_status)
        end

        it 'updates that issue' do
          expect(subject).not_to receive(:create_issue)
          expect(::Gitlab).to receive(:edit_issue)

          expect { subject.invoke! }
            .to output(%r{Found existing issue: http://existing-issue.url\n.*Issue updated}).to_stdout
        end

        context 'with a passing test' do
          it 'adds a passed label' do
            expect(subject).to receive(:pipeline).and_return('production')
            expect(::Gitlab).to receive(:edit_issue).with(anything, anything, labels: %w[production::passed])

            expect { subject.invoke! }.to output.to_stdout
          end

          it 'does not add a note' do
            allow(subject).to receive(:update_labels)

            expect(subject).to receive(:note_status).and_call_original
            expect(::Gitlab).not_to receive(:create_issue_note)

            expect { subject.invoke! }.to output.to_stdout
          end

          context 'with an existing failed label' do
            let(:labels) { %w[staging::failed] }

            it 'replaces the label' do
              expect(subject).to receive(:pipeline).and_return('staging').twice
              expect(::Gitlab).to receive(:edit_issue).with(anything, anything, labels: %w[staging::passed])

              expect { subject.invoke! }.to output.to_stdout
            end
          end
        end

        context 'with a failed test' do
          let(:test_xml) { '<testcase name="test-name" file="test-file"><failure message="An Error Here">Test Stacktrace</failure></testcase>' }

          it 'adds a failed label' do
            expect(subject).to receive(:pipeline).and_return('production')
            expect(::Gitlab).to receive(:edit_issue).with(anything, anything, labels: %w[production::failed])

            expect { subject.invoke! }.to output.to_stdout
          end

          context 'when reporting for master pipelines' do
            it 'can report from gitlab-qa' do
              ClimateControl.modify(CI_PROJECT_NAME: 'gitlab-qa') do
                expect(::Gitlab).to receive(:edit_issue).with(anything, anything, labels: %w[master::failed])

                expect { subject.invoke! }.to output.to_stdout
              end
            end

            it 'can report from gitlab-qa-mirror' do
              ClimateControl.modify(CI_PROJECT_NAME: 'gitlab-qa-mirror') do
                expect(::Gitlab).to receive(:edit_issue).with(anything, anything, labels: %w[master::failed])

                expect { subject.invoke! }.to output.to_stdout
              end
            end
          end

          context 'with an existing passed label' do
            let(:labels) { %w[staging::passed] }

            it 'replaces the label' do
              expect(subject).to receive(:pipeline).and_return('staging').twice
              expect(::Gitlab).to receive(:edit_issue).with(anything, anything, labels: %w[staging::failed])

              expect { subject.invoke! }.to output.to_stdout
            end
          end

          context 'when reporting a specific job' do
            let(:failure_summary) { ":x: ~\"staging::failed\" in job `test-job` in http://job_url" }
            let(:note_content) { "#{failure_summary}\n\nError:\n```\nAn Error Here\n```\n\nStacktrace:\n```\nTest Stacktrace\n```\n" }

            before do
              allow(subject).to receive(:update_labels)
              allow(subject).to receive(:note_status).and_call_original
            end

            around do |example|
              ClimateControl.modify(
                CI_JOB_URL: 'http://job_url',
                CI_JOB_NAME: 'test-job',
                CI_PROJECT_NAME: 'staging'
              ) { example.run }
            end

            it 'adds a note that the test failed and a stack trace' do
              expect(::Gitlab).to receive(:issue_discussions).and_return([])
              expect(::Gitlab).to receive(:create_issue_note)
                .with(anything, anything, note_content)

              expect { subject.invoke! }.to output.to_stdout
            end

            context 'with an existing discussion' do
              let(:existing_discussion) { Struct.new(:notes, :id).new(['body' => note_content], 0) }

              it 'adds a note to the discussion with no stack trace' do
                expect(::Gitlab).to receive(:issue_discussions).and_return([existing_discussion])
                expect(::Gitlab).to receive(:add_note_to_issue_discussion_as_thread)
                  .with('valid-project', 0, 0, body: failure_summary)

                expect { subject.invoke! }.to output.to_stdout
              end

              context 'when the error or stack trace do not match' do
                let(:existing_discussion) do
                  Struct.new(:notes, :id)
                        .new(['body' => "#{failure_summary}\n\nError:\n```\nThis time it's different\n```\n\nStacktrace:\n```\nAlso different\n```\n"], 0)
                end

                it 'adds a note as a new discussion' do
                  expect(::Gitlab).to receive(:issue_discussions).and_return([existing_discussion])
                  expect(::Gitlab).not_to receive(:add_note_to_issue_discussion_as_thread)
                  expect(::Gitlab).to receive(:create_issue_note)
                    .with(anything, anything, note_content)

                  expect { subject.invoke! }.to output.to_stdout
                end
              end

              context 'with a different job name and environment' do
                around do |example|
                  ClimateControl.modify(
                    CI_JOB_URL: 'http://job_url',
                    CI_JOB_NAME: 'different-test-job',
                    CI_PROJECT_NAME: 'production'
                  ) { example.run }
                end

                it 'still matches the error and stack trace' do
                  expect(::Gitlab).to receive(:issue_discussions).and_return([existing_discussion])
                  expect(::Gitlab).to receive(:add_note_to_issue_discussion_as_thread)
                    .with('valid-project', 0, 0, body: ":x: ~\"production::failed\" in job `different-test-job` in http://job_url")

                  expect { subject.invoke! }.to output.to_stdout
                end
              end
            end

            context 'when the test is quarantined' do
              let(:failure_summary) { ":x: ~\"staging::failed\" ~\"quarantine\" in job `test-job-quarantine` in http://job_url" }

              around do |example|
                ClimateControl.modify(
                  CI_JOB_URL: 'http://job_url',
                  CI_JOB_NAME: 'test-job-quarantine'
                ) { example.run }
              end

              it 'applies a quarantine label and includes the same in the summary' do
                allow(subject).to receive(:update_labels).and_call_original
                allow(subject).to receive(:pipeline).and_return('staging').twice
                allow(::Gitlab).to receive(:issue_discussions).and_return([])

                expect(::Gitlab).to receive(:edit_issue).with(anything, anything, labels: %w[staging::failed quarantine])
                expect(::Gitlab).to receive(:create_issue_note)
                  .with(anything, anything, note_content)

                expect { subject.invoke! }.to output.to_stdout
              end
            end

            context 'when a quarantined test is dequarantined' do
              let(:labels) { %w[quarantine] }

              it 'removes the quarantine label' do
                allow(subject).to receive(:update_labels).and_call_original
                allow(subject).to receive(:pipeline).and_return('staging').exactly(3).times
                allow(::Gitlab).to receive(:issue_discussions).and_return([])

                expect(::Gitlab).to receive(:edit_issue).with(anything, anything, labels: %w[staging::failed])
                expect(::Gitlab).to receive(:create_issue_note)
                  .with(anything, anything, note_content)

                expect { subject.invoke! }.to output.to_stdout
              end
            end
          end
        end
      end
    end
  end
end
