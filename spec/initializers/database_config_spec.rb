# frozen_string_literal: true

require 'spec_helper'

describe 'Database config initializer' do
  subject do
    load Rails.root.join('config/initializers/database_config.rb')
  end

  let(:max_threads) { 8 }

  before do
    allow(ActiveRecord::Base).to receive(:establish_connection)
    allow(Gitlab::Runtime).to receive(:max_threads).and_return(max_threads)
  end

  context "when configuring the connection pool size" do
    context "and no pool size has been configured" do
      context "and the number of threads plus headroom does not exceed the maximum pool size" do
        it "sets it to the number of threads plus headroom" do
          stub_database_config(pool_size: nil)

          expect { subject }.to change { Gitlab::Database.config['pool'] }
            .from(nil).to(max_threads + Gitlab::Database::POOL_HEADROOM)
        end
      end

      context "and the number of threads plus headroom exceed the maximum pool size" do
        it "sets it to the maximum pool size" do
          stub_database_config(pool_size: nil)
          stub_const('Gitlab::Database::MAX_POOL_SIZE', max_threads + Gitlab::Database::POOL_HEADROOM - 1)

          expect { subject }.to change { Gitlab::Database.config['pool'] }.from(nil).to(Gitlab::Database::MAX_POOL_SIZE)
        end
      end
    end

    context "and a pool size has been configured" do
      context "and it is smaller than the number of threads plus headroom" do
        it "sets it to the number of threads plus headroom" do
          stub_database_config(pool_size: max_threads + Gitlab::Database::POOL_HEADROOM - 1)

          expect { subject }.to change { Gitlab::Database.config['pool'] }.to(max_threads + Gitlab::Database::POOL_HEADROOM)
        end
      end

      context "and it is greater than or equal to the number of threads plus headroom" do
        it "uses the configured pool size" do
          stub_database_config(pool_size: max_threads + Gitlab::Database::POOL_HEADROOM + 1)

          expect { subject }.not_to change { Gitlab::Database.config['pool'] }
        end
      end

      context "and it is greater than the maximum pool size" do
        it "sets it to the maximum pool size" do
          stub_database_config(pool_size: Gitlab::Database::MAX_POOL_SIZE + 1)

          expect { subject }.to change { Gitlab::Database.config['pool'] }.to(Gitlab::Database::MAX_POOL_SIZE)
        end
      end
    end
  end

  def stub_database_config(pool_size:)
    config = {
      'adapter' => 'postgresql',
      'host' => 'db.host.com',
      'pool' => pool_size
    }.compact

    allow(Gitlab::Database).to receive(:config).and_return(config)
  end
end
