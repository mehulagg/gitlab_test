require 'nokogiri'
require 'table_print'

module Gitlab
  module QA
    module Report
      class SummaryTable
        def self.create(input_files:)
          "```\n#{TablePrint::Printer.table_print(collect_results(input_files))}```\n"
        end

        # rubocop:disable Metrics/AbcSize
        def self.collect_results(input_files)
          stage_wise_results = []

          Dir.glob(input_files).each do |report_file|
            stage_hash = {}
            stage_hash["Dev Stage"] = File.basename(report_file, ".*").capitalize

            report_stats = Nokogiri::XML(File.open(report_file)).children[0].attributes

            stage_hash["Total"] = report_stats["tests"].value
            stage_hash["Failures"] = report_stats["failures"].value
            stage_hash["Errors"] = report_stats["errors"].value
            stage_hash["Skipped"] = report_stats["skipped"].value
            stage_hash["Result"] = result_emoji(report_stats)

            stage_wise_results << stage_hash
          end

          stage_wise_results
        end
        # rubocop:enable Metrics/AbcSize

        def self.result_emoji(report_stats)
          report_stats["failures"].value.to_i.positive? || report_stats["errors"].value.to_i.positive? ? "❌" : "✅"
        end
      end
    end
  end
end
