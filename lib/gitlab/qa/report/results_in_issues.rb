# frozen_string_literal: true

require 'nokogiri'
require 'gitlab'
require 'active_support/core_ext/enumerable'

module Gitlab
  # Monkey patch the Gitlab client to use the correct API path and add required methods
  class Client
    def team_member(project, id)
      get("/projects/#{url_encode(project)}/members/all/#{id}")
    end

    def issue_discussions(project, issue_id, options = {})
      get("/projects/#{url_encode(project)}/issues/#{issue_id}/discussions", query: options)
    end

    def add_note_to_issue_discussion_as_thread(project, issue_id, discussion_id, options = {})
      post("/projects/#{url_encode(project)}/issues/#{issue_id}/discussions/#{discussion_id}/notes", query: options)
    end
  end

  module QA
    module Report
      # Uses the API to create or update GitLab issues with the results of tests from RSpec report files.
      # The GitLab client is used for API access: https://github.com/NARKOZ/gitlab
      class ResultsInIssues
        MAINTAINER_ACCESS_LEVEL = 40
        MAX_TITLE_LENGTH = 255

        def initialize(token:, input_files:, project: nil)
          @token = token
          @files = Array(input_files)
          @project = project
        end

        def invoke!
          configure_gitlab_client

          validate_input!

          puts "Reporting test results in `#{files.join(',')}` as issues in project `#{project}` via the API at `#{Runtime::Env.gitlab_api_base}`."

          Dir.glob(files).each do |file|
            puts "Reporting tests in #{file}"
            Nokogiri::XML(File.open(file)).xpath('//testcase').each do |test|
              report_test(test)
            end
          end
        end

        private

        attr_reader :files, :token, :project

        def validate_input!
          assert_project!
          assert_input_files!(files)
          assert_user_permission!
        end

        def assert_project!
          return if project

          abort "Please provide a valid project ID or path with the `-p/--project` option!"
        end

        def assert_input_files!(files)
          return if Dir.glob(files).any?

          abort "Please provide valid JUnit report files. No files were found matching `#{files.join(',')}`"
        end

        def assert_user_permission!
          user = Gitlab.user
          member = Gitlab.team_member(project, user.id)

          abort_not_permitted if member.access_level < MAINTAINER_ACCESS_LEVEL
        rescue Gitlab::Error::NotFound
          abort_not_permitted
        end

        def abort_not_permitted
          abort "You must have at least Maintainer access to the project to use this feature."
        end

        def configure_gitlab_client
          Gitlab.configure do |config|
            config.endpoint = Runtime::Env.gitlab_api_base
            config.private_token = token
          end
        end

        def report_test(test)
          return if test.search('skipped').any?

          puts "Reporting test: #{test['file']} | #{test['name']}"

          issue = find_issue(test)
          if issue
            puts "Found existing issue: #{issue.web_url}"
          else
            issue = create_issue(test)
            puts "Created new issue: #{issue.web_url}"
          end

          update_labels(issue, test)
          note_status(issue, test)

          puts "Issue updated"
        end

        def create_issue(test)
          puts "Creating issue..."

          Gitlab.create_issue(
            project,
            title_from_test(test),
            { description: "### Full description\n\n#{search_safe(test['name'])}\n\n### File path\n\n#{test['file']}", labels: 'status::automated' }
          )
        end

        def find_issue(test)
          issues = Gitlab.issues(project, { search: search_term(test) })
            .auto_paginate
            .select { |issue| issue.state == 'opened' && issue.title.strip == title_from_test(test) }

          warn(%(Too many issues found with the file path "#{test['file']}" and name "#{test['name']}")) if issues.many?

          issues.first
        end

        def search_term(test)
          %("#{test['file']}" "#{search_safe(test['name'])}")
        end

        def title_from_test(test)
          title = "#{partial_file_path(test['file'])} | #{search_safe(test['name'])}".strip

          return title unless title.length > MAX_TITLE_LENGTH

          "#{title[0...MAX_TITLE_LENGTH - 3]}..."
        end

        def partial_file_path(path)
          path.match(/((api|browser_ui).*)/i)[1]
        end

        def search_safe(value)
          value.delete('"')
        end

        def note_status(issue, test)
          return if failures(test).empty?

          note = note_content(test)

          Gitlab.issue_discussions(project, issue.iid, order_by: 'created_at', sort: 'asc').each do |discussion|
            return add_note_to_discussion(issue.iid, discussion.id) if new_note_matches_discussion?(note, discussion)
          end

          Gitlab.create_issue_note(project, issue.iid, note)
        end

        def note_content(test)
          errors = failures(test).each_with_object([]) do |failure, text|
            text << <<~TEXT
              Error:
              ```
              #{failure['message']}
              ```

              Stacktrace:
              ```
              #{failure.content}
              ```
            TEXT
          end.join("\n\n")

          "#{failure_summary}\n\n#{errors}"
        end

        def failure_summary
          summary = [":x: ~\"#{pipeline}::failed\""]
          summary << "~\"quarantine\"" if quarantine_job?
          summary << "in job `#{Runtime::Env.ci_job_name}` in #{Runtime::Env.ci_job_url}"
          summary.join(' ')
        end

        def quarantine_job?
          Runtime::Env.ci_job_name&.include?('quarantine')
        end

        def new_note_matches_discussion?(note, discussion)
          note_error = error_and_stack_trace(note)
          discussion_error = error_and_stack_trace(discussion.notes.first['body'])

          return false if note_error.empty? || discussion_error.empty?

          note_error == discussion_error
        end

        def error_and_stack_trace(text)
          result = text.strip[/Error:(.*)/m, 1].to_s

          warn "Could not find `Error:` in text: #{text}" if result.empty?

          result
        end

        def add_note_to_discussion(issue_iid, discussion_id)
          Gitlab.add_note_to_issue_discussion_as_thread(project, issue_iid, discussion_id, body: failure_summary)
        end

        def update_labels(issue, test)
          labels = issue.labels
          labels.delete_if { |label| label.start_with?("#{pipeline}::") }
          labels << (failures(test).empty? ? "#{pipeline}::passed" : "#{pipeline}::failed")
          labels << "Enterprise Edition" if ee_test?(test)
          quarantine_job? ? labels << "quarantine" : labels.delete("quarantine")

          Gitlab.edit_issue(project, issue.iid, labels: labels)
        end

        def ee_test?(test)
          test['file'] =~ %r{features/ee/(api|browser_ui)}
        end

        def failures(test)
          test.search('failure')
        end

        def pipeline
          # Gets the name of the pipeline the test was run in, to be used as the key of a scoped label
          #
          # Tests can be run in several pipelines:
          #   gitlab-qa, nightly, master, staging, canary, production, preprod, and MRs
          #
          # Some of those run in their own project, so CI_PROJECT_NAME is the name we need. Those are:
          #   nightly, staging, canary, production, and preprod
          #
          # MR, master, and gitlab-qa tests run in gitlab-qa, but we only want to report tests run on master
          # because the other pipelines will be monitored by the author of the MR that triggered them.
          # So we assume that we're reporting a master pipeline if the project name is 'gitlab-qa'.

          Runtime::Env.ci_project_name.to_s.start_with?('gitlab-qa') ? 'master' : Runtime::Env.ci_project_name
        end
      end
    end
  end
end
