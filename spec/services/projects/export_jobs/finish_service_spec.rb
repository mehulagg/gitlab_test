# frozen_string_literal: true

require 'spec_helper'

describe Projects::ExportJobs::FinishService do
  let(:job) { create(:project_export_job) }

  describe '#execute' do
    context 'when valid' do
      subject { described_class.new(job.project).execute(job) }

      before do
        job.start!
      end

      it 'sets state to finish' do
        expect { subject }.to change { job.status }.from(1).to(2)
      end
    end

    context 'when state cannot be changed to finish' do
      subject { described_class.new(job.project).execute(job) }

      it 'does nothing' do
        expect { subject }.not_to change { job.status }
      end
    end
  end
end
