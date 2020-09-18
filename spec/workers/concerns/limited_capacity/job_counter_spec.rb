# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LimitedCapacity::JobCounter, :clean_gitlab_redis_shared_state do
  let(:job_counter) do
    described_class.new('namespace')
  end

  describe '#register' do
    it 'adds jid to the set' do
      job_counter.register('a-job-id')

      expect(job_counter.running_jids).to contain_exactly('a-job-id')
    end

    it 'updates the counter' do
      expect { job_counter.register('a-job-id') }
        .to change { job_counter.count }
        .from(0)
        .to(1)
    end
  end

  describe '#remove' do
    before do
      job_counter.register(%w[a-job-id other-job-id])
    end

    it 'removes jid from the set' do
      job_counter.remove('other-job-id')

      expect(job_counter.running_jids).to contain_exactly('a-job-id')
    end

    it 'updates the counter' do
      expect { job_counter.remove('other-job-id') }
        .to change { job_counter.count }
        .from(2)
        .to(1)
    end
  end

  describe '#clean_up' do
    before do
      job_counter.register('a-job-id')
    end

    context 'with running jobs' do
      before do
        expect(Gitlab::SidekiqStatus).to receive(:completed_jids)
          .with(%w[a-job-id])
          .and_return([])
      end

      it 'does not remove the jid from the set' do
        expect { job_counter.clean_up }
          .not_to change { job_counter.running_jids.include?('a-job-id') }
      end
    end

    context 'with completed jobs' do
      it 'removes the jid from the set' do
        expect { job_counter.clean_up }
          .to change { job_counter.running_jids.include?('a-job-id') }
      end

      it 'updates the counter' do
        expect { job_counter.clean_up }
          .to change { job_counter.count }
          .from(1)
          .to(0)
      end
    end
  end
end
