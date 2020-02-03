require 'optparse'

module Gitlab
  module QA
    class Runner
      # These options are implemented in the QA framework (i.e., in the CE/EE codebase)
      # They're included here so that gitlab-qa treats them as valid options
      PASS_THROUGH_OPTS = [
        ['--address URL', 'Address of the instance to test'],
        ['--enable-feature FEATURE_FLAG', 'Enable a feature before running tests'],
        ['--mattermost-address URL', 'Address of the Mattermost server'],
        ['--parallel', 'Execute tests in parallel'],
        ['--loop', 'Execute tests in a loop']
      ].freeze

      # rubocop:disable Metrics/AbcSize
      def self.run(args)
        report_options = {}

        options = OptionParser.new do |opts|
          opts.banner = 'Usage: gitlab-qa [options] Scenario URL [[--] path] [rspec_options]'

          PASS_THROUGH_OPTS.each do |opt|
            opts.on(*opt)
          end

          opts.on('--prepare-stage-reports FILES', 'Prepare separate reports for each Stage from the provided JUnit XML files') do |files|
            report_options[:prepare_stage_reports] = true
            report_options[:input_files] = files if files
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

        if args.size >= 1
          if report_options[:prepare_stage_reports]
            report_options.delete(:prepare_stage_reports)
            Gitlab::QA::Report::PrepareStageReports.new(**report_options).invoke!

            exit
          end

          Scenario
            .const_get(args.shift)
            .perform(*args)
        else
          puts options
          exit 1
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
