# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Parsers::Terraform::Tfplan do
  describe '#parse!' do
    let_it_be(:artifact) { create(:ci_job_artifact, :terraform) }

    let(:reports) { Gitlab::Ci::Reports::TerraformReports.new }

    context 'when data is tfplan.json' do
      context 'when there is no data' do
        it 'reports an invalid_json_keys error' do
          plan = '{}'

          expect { subject.parse!(plan, reports, artifact: artifact) }.not_to raise_error

          expect(reports.plans).to match(
            a_hash_including(
              'tfplan.json' => a_hash_including(
                'tf_report_error' => :invalid_json_keys
              )
            )
          )
        end
      end

      context 'when there is data' do
        it 'parses JSON and returns a report' do
          plan = '{ "create": 0, "update": 1, "delete": 0 }'

          expect { subject.parse!(plan, reports, artifact: artifact) }.not_to raise_error

          expect(reports.plans).to match(
            a_hash_including(
              'tfplan.json' => a_hash_including(
                'create' => 0,
                'update' => 1,
                'delete' => 0
              )
            )
          )

          expect(reports.plans.dig('tfplan.json', 'tf_report_error')).to be_nil
        end
      end
    end

    context 'when data is not tfplan.json' do
      it 'reports an invalid_json_format error' do
        plan = { 'create' => 0, 'update' => 1, 'delete' => 0 }.to_s

        expect { subject.parse!(plan, reports, artifact: artifact) }.not_to raise_error

        expect(reports.plans).to match(
          a_hash_including(
            'tfplan.json' => a_hash_including(
              'tf_report_error' => :invalid_json_format
            )
          )
        )
      end
    end

    context 'when the plan has external errors' do
      it 'reports an unknown_error error' do
        expect { subject.parse!(nil, reports, artifact: artifact) }.not_to raise_error

        expect(reports.plans).to match(
          a_hash_including(
            'tfplan.json' => a_hash_including(
              'tf_report_error' => :unknown_error
            )
          )
        )
      end
    end
  end
end
