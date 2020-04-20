require 'optparse'

module Gitlab
  module QA
    class Reporter
      # rubocop:disable Metrics/AbcSize
      def self.invoke(args)
        report_options = {}
        slack_options = {}

        options = OptionParser.new do |opts|
          opts.banner = 'Usage: gitlab-qa-reporter [options]'

          opts.on('--prepare-stage-reports FILES', 'Prepare separate reports for each Stage from the provided JUnit XML files') do |files|
            report_options[:prepare_stage_reports] = true
            report_options[:input_files] = files if files
          end

          opts.on('--report-in-issues FILES', String, 'Report test results from JUnit XML files in GitLab issues') do |files|
            report_options[:report_in_issues] = true
            report_options[:input_files] = files if files
          end

          opts.on('-p', '--project PROJECT_ID', String, 'A valid project ID. Can be an integer or a group/project string. Required by --report-in-issues') do |value|
            report_options[:project] = value
          end

          opts.on('-t', '--token ACCESS_TOKEN', String, 'A valid access token. Used by --report-in-issues') do |value|
            report_options[:token] = value
          end

          opts.on('--post-to-slack MSG', 'Post message to slack') do |msg|
            slack_options[:post_to_slack] = true
            slack_options[:message] = msg
          end

          opts.on('--include-summary-table FILES', 'Create a results summary table to post to slack. To be used with --post-to-slack.') do |files|
            raise 'This option should be used with --post-to-slack.' unless slack_options[:post_to_slack]

            slack_options[:message] = slack_options[:message] + "\n\n" + Gitlab::QA::Report::SummaryTable.create(input_files: files)
          end

          opts.on('--update-screenshot-path FILES', "Update the path to screenshots to container's host") do |files|
            report_options[:update_screenshot_path] = true
            report_options[:files] = files
          end

          opts.on_tail('-v', '--version', 'Show the version') do
            require 'gitlab/qa/version'
            puts "#{$PROGRAM_NAME} : #{VERSION}"
            exit
          end

          opts.on_tail('-h', '--help', 'Show the usage') do
            puts opts
            exit
          end

          opts.parse(args)
        end

        if args.any?
          if report_options[:prepare_stage_reports]
            report_options.delete(:prepare_stage_reports)
            Gitlab::QA::Report::PrepareStageReports.new(**report_options).invoke!

            exit
          end

          if report_options[:report_in_issues]
            report_options.delete(:report_in_issues)
            report_options[:token] = Runtime::TokenFinder.find_token!(report_options[:token])
            Gitlab::QA::Report::ResultsInIssues.new(**report_options).invoke!

            exit
          end

          if slack_options[:post_to_slack]
            slack_options.delete(:post_to_slack)
            Gitlab::QA::Slack::PostToSlack.new(**slack_options).invoke!

            exit
          end

          if report_options[:update_screenshot_path]
            report_options.delete(:update_screenshot_path)

            Gitlab::QA::Report::UpdateScreenshotPath.new(**report_options).invoke!

            exit
          end
        else
          puts options
          exit 1
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
