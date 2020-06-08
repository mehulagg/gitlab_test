# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Terraform
        class Tfplan
          TfplanParserError = Class.new(Gitlab::Ci::Parsers::ParserError)

          def parse!(json_data, terraform_reports, artifact:)
            job_path = Gitlab::Routing.url_helpers.project_job_path(artifact.job.project, artifact.job)

            tfplan = Gitlab::Json.parse(json_data).tap do |parsed_data|
              parsed_data['job_path'] = job_path
              parsed_data['tf_report_error'] = :invalid_json_keys unless valid_supported_keys?(parsed_data)
            end

            terraform_reports.add_plan(artifact.filename, tfplan)
          rescue JSON::ParserError
            terraform_reports.add_plan(artifact.filename, {
              'job_path' => job_path,
              'tf_report_error' => :invalid_json_format
            })
          rescue
            terraform_reports.add_plan(artifact.filename, {
              'job_path' => job_path,
              'tf_report_error' => :unknown_error
            })
          end

          private

          def valid_supported_keys?(tfplan)
            tfplan.keys == %w[create update delete job_path]
          end
        end
      end
    end
  end
end
