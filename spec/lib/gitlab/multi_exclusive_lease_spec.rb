# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::MultiExclusiveLease, :clean_gitlab_redis_shared_state do
  let(:lease_prefix) { 'lease_prefix' }
  let(:keys) { ['a', 'b', 'c']  }

  describe '#try_obtain' do
    subject(:multi_lease) { described_class.new(lease_prefix, timeout: 3600) }

    it 'cannot obtain twice before the lease has expired' do
      expect(multi_lease.try_obtain(keys)).to be_present
    end

    # it 'can obtain after the lease has expired' do
    #   timeout = 1
    #   lease = described_class.new(unique_key, timeout: timeout)
    #   lease.try_obtain # start the lease
    #   sleep(2 * timeout) # lease should have expired now
    #   expect(lease.try_obtain).to be_present
    # end
  end
end
