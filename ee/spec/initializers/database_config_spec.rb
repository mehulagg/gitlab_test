# frozen_string_literal: true

require 'spec_helper'

describe 'Database config initializer for GitLab EE' do
  it_behaves_like 'a database config initializer'

  def db_pool_size
    Rails.configuration.geo_database['pool']
  end

  def stub_database_config(pool_size:)
    config = {
      'adapter' => 'postgresql',
      'host' => 'db.host.com',
      'pool' => pool_size
    }.compact

    allow(Rails.configuration).to receive(:geo_database).and_return(config)
  end
end
