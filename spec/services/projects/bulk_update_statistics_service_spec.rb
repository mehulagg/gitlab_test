# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::BulkUpdateStatisticsService do
  let_it_be(:projects) { create_list :project, 2 }

  let(:project_1) { projects.first }
  let(:project_2) { projects.last }
  let(:statistics_1) { project_1.statistics }
  let(:statistics_2) { project_2.statistics }

  let(:data) { { project_1 => 13, project_2 => 14 } }
  let(:service) { described_class.new(data, statistic: :build_artifacts_size) }

  describe '#execute' do
    it 'increases the statistics and enqueues multiple namespace aggregation job' do
      expect(Namespaces::ScheduleAggregationWorker)
        .to receive(:bulk_perform_async).with([[project_1.namespace_id], [project_2.namespace_id]])

      expect { service.execute }
        .to change { statistics_1.reload.build_artifacts_size }.by(13)
        .and change { statistics_2.reload.build_artifacts_size }.by(14)
    end

    context 'with only one project' do
      let(:data) { { project_1 => 13 } }

      it 'increases the statistic and enqueues a namespace aggregation job' do
        expect(Namespaces::ScheduleAggregationWorker)
          .to receive(:perform_async).with(project_1.namespace_id)

        expect { service.execute }
          .to change { statistics_1.reload.build_artifacts_size }.by(13)
      end
    end

    context 'with a nil project' do
      let(:data) { { nil => 13 } }

      it 'does not crash when a project is missing' do
        expect(service.execute).to be_truthy
      end
    end
  end
end
