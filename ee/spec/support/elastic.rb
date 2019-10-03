# frozen_string_literal: true

RSpec.configure do |config|
  def current_es_index
    @current_es_index ||= create(:elasticsearch_index)
  end

  # Use :elastic_stub when you only need an index configuration in the DB,
  # this is necessary when you want to use our ES class/instance proxies.
  config.before(:each, :elastic_stub) do
    stub_ee_application_setting(elasticsearch_read_index: current_es_index)
  end

  # Use :elastic when you need a real ES index.
  config.before(:each, :elastic) do
    Gitlab::Elastic::Helper.create_empty_index(current_es_index)
    stub_ee_application_setting(elasticsearch_read_index: current_es_index)
  end

  config.after(:each, :elastic) do
    Gitlab::Elastic::Helper.delete_index(current_es_index)
  end
end
