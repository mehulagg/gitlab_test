# frozen_string_literal: true

require 'spec_helper'

describe Projects::ExportJobs::CreateService do
  let(:project) { create(:project) }

  describe '#execute' do
    subject { described_class.new(project).execute(SecureRandom.hex(8)) }

    it 'creates record' do
      expect { subject }.to change { project.export_jobs.count }.from(0).to(1)
    end

    context 'when record is already present' do
      before do
        described_class.new(project).execute('jid')
      end

      it 'does not create record' do
        expect { described_class.new(project).execute('jid') }.not_to change { project.export_jobs.count }
      end
    end

    it 'sets status to started' do
      job = subject

      expect(job.status).to eq(1)
    end
  end
end
