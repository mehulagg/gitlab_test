# frozen_string_literal: true

require 'spec_helper'

module Gitlab
  module Ci
    class YamlProcessor
      RSpec.describe Result do
        include StubRequests

        let(:user) { create(:user) }
        let(:ci_config) { Gitlab::Ci::Config.new(config_content, user: user) }
        let(:result) { described_class.new(ci_config: ci_config, warnings: ci_config&.warnings) }

        describe '#expanded_yaml_config' do
          subject(:expanded_yaml_config) { result.expanded_yaml_config }

          let(:config_content) do
            YAML.dump(
              include: { remote: 'https://example.com/sample.yml' },
              test: { stage: 'test', script: 'echo' }
            )
          end

          let(:included_yml) do
            YAML.dump(
              another_test: { stage: 'test', script: 'echo 2' }
            )
          end

          before do
            stub_full_request('https://example.com/sample.yml').to_return(body: included_yml)
          end

          it 'returns expanded yaml config' do
            expanded_config = YAML.safe_load(expanded_yaml_config, [Symbol])
            included_config = YAML.safe_load(included_yml, [Symbol])

            expect(expanded_config).to include(*included_config.keys)
          end
        end
      end
    end
  end
end
