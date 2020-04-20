require 'nokogiri'

module Gitlab
  module QA
    module Report
      class UpdateScreenshotPath
        def initialize(files:)
          @files = files
        end

        REGEX = %r{(?<gitlab_qa_run>gitlab-qa-run-.*?(?=\/))\/(?<gitlab_ce_ee_qa>gitlab-(ee|ce)-qa-.*?(?=\/))}

        def invoke!
          Dir.glob(@files).each do |rspec_report_file|
            report = rewrite_each_screenshot_path(rspec_report_file)

            File.write(rspec_report_file, report)

            puts "Saved #{rspec_report_file}"
          end
        end

        private

        def rewrite_each_screenshot_path(rspec_report_file)
          report = Nokogiri::XML(File.open(rspec_report_file))

          match_data = rspec_report_file.match(REGEX)

          report.xpath('//system-out').each do |system_out|
            system_out.content = system_out.content.gsub(File.join(Docker::Volumes::QA_CONTAINER_WORKDIR, 'tmp'), "#{match_data[:gitlab_qa_run]}/#{match_data[:gitlab_ce_ee_qa]}")
          end

          report.to_s
        end
      end
    end
  end
end
