require 'nokogiri'

module Gitlab
  module QA
    module Report
      class PrepareStageReports
        def initialize(input_files:)
          @input_files = input_files
        end

        # Create a new JUnit report file for each Stage, containing tests from that Stage alone
        def invoke!
          collate_test_cases(@input_files).each do |stage, tests|
            filename = "#{stage}.xml"

            File.write(filename, new_junit_report(tests))

            puts "Saved #{filename}"
          end
        end

        private

        def collate_test_cases(input_files)
          # Collect the test cases from the original reports and group them by Stage
          testcases = {}

          Dir.glob(input_files).each do |rspec_report_file|
            report = Nokogiri::XML(File.open(rspec_report_file))
            report.xpath('//testcase').each do |test|
              # The test file paths could start with any of
              #  /qa/specs/features/api/<stage>
              #  /qa/specs/features/browser_ui/<stage>
              #  /qa/specs/features/ee/api/<stage>
              #  /qa/specs/features/ee/browser_ui/<stage>
              # For now we assume the Stage is whatever follows api/ or browser_ui/
              stage = strip_number_prefix(test['file'].match(%r{(api|browser_ui)/([a-z0-9_]+)}i)[2])
              testcases[stage] = [] unless testcases.key?(stage)
              testcases[stage] << test
            end
          end

          testcases
        end

        def strip_number_prefix(stage)
          stage.sub(/^\d+_/, '')
        end

        def new_junit_report(testcases)
          report = Nokogiri::XML::Document.new
          testsuite_node = report.create_element('testsuite', name: 'rspec', **collect_stats(testcases))
          report.root = testsuite_node

          testcases.each do |test|
            testsuite_node.add_child(test)
          end

          report.to_s
        end

        def collect_stats(testcases)
          stats = {
            tests: testcases.size,
            failures: 0,
            errors: 0,
            skipped: 0
          }

          testcases.each do |test|
            stats[:failures] += 1 unless test.search('failure').empty?
            stats[:errors] += 1 unless test.search('error').empty?
            stats[:skipped] += 1 unless test.search('skipped').empty?
          end

          stats
        end
      end
    end
  end
end
