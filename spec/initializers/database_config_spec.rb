# frozen_string_literal: true

require 'spec_helper'

describe 'Database config initializer' do
  it_behaves_like 'a database config initializer'

  def db_pool_size
    Gitlab::Database.config['pool']
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
