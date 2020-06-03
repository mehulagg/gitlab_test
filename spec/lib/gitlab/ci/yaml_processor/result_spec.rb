# frozen_string_literal: true

require 'spec_helper'

module Gitlab
  module Ci
    RSpec.describe YamlProcessor::Result do
      let(:result) { described_class.new(ci_config: ci_config, errors: errors, warnings: warnings) }
      let(:warnings) { [] }
      let(:errors) { [] }

      describe '#valid?' do
        subject { result.valid? }

        context 'when ci_config is not present' do
          let(:ci_config) { nil }

          it { is_expected.to be_falsey }
        end

        context 'when ci_config is present' do
          let(:ci_config) { double(:ci_config) }

          context 'when there are any errors' do
            let(:errors) { ['an error message' ] }

            it { is_expected.to be_falsey }
          end

          context 'when there are no errors' do
            it { is_expected.to be_truthy }
          end
        end
      end

      describe '#build_attributes' do
        subject { result.build_attributes(:rspec) }

        let(:ci_config) { Ci::Config.new(config) }

        describe 'attributes list' do
          let(:config) do
            YAML.dump(
              before_script: ['pwd'],
              rspec: {
                script: 'rspec',
                interruptible: true
              }
            )
          end

          it 'returns valid build attributes' do
            expect(subject).to eq({
              stage: "test",
              stage_idx: 2,
              name: "rspec",
              only: { refs: %w[branches tags] },
              options: {
                before_script: ["pwd"],
                script: ["rspec"]
              },
              interruptible: true,
              allow_failure: false,
              when: "on_success",
              yaml_variables: [],
              scheduling_type: :stage
            })
          end
        end

        context 'with job rules' do
          let(:config) do
            YAML.dump(
              rspec: {
                script: 'rspec',
                rules: [
                  { if: '$CI_COMMIT_REF_NAME == "master"' },
                  { changes: %w[README.md] }
                ]
              }
            )
          end

          it 'returns valid build attributes' do
            expect(subject).to eq({
              stage: 'test',
              stage_idx: 2,
              name: 'rspec',
              options: { script: ['rspec'] },
              rules: [
                { if: '$CI_COMMIT_REF_NAME == "master"' },
                { changes: %w[README.md] }
              ],
              allow_failure: false,
              when: 'on_success',
              yaml_variables: [],
              scheduling_type: :stage
            })
          end
        end

        describe 'coverage entry' do
          describe 'code coverage regexp' do
            let(:config) do
              YAML.dump(rspec: { script: 'rspec',
                                 coverage: '/Code coverage: \d+\.\d+/' })
            end

            it 'includes coverage regexp in build attributes' do
              expect(subject)
                .to include(coverage_regex: 'Code coverage: \d+\.\d+')
            end
          end
        end

        describe 'tags entry with default values' do
          it 'applies default values' do
            config = YAML.dump({ default: { tags: %w[A B] },
                                 rspec: { script: "rspec" } })

            result = Gitlab::Ci::YamlProcessor.new(config).execute

            expect(result.stage_builds_attributes("test").size).to eq(1)
            expect(result.stage_builds_attributes("test").first).to eq({
              stage: "test",
              stage_idx: 2,
              name: "rspec",
              only: { refs: %w[branches tags] },
              options: { script: ["rspec"] },
              scheduling_type: :stage,
              tag_list: %w[A B],
              allow_failure: false,
              when: "on_success",
              yaml_variables: []
            })
          end
        end

        describe 'interruptible entry' do
          describe 'interruptible job' do
            let(:config) do
              YAML.dump(rspec: { script: 'rspec', interruptible: true })
            end

            it { expect(subject[:interruptible]).to be_truthy }
          end

          describe 'interruptible job with default value' do
            let(:config) do
              YAML.dump(rspec: { script: 'rspec' })
            end

            it { expect(subject).not_to have_key(:interruptible) }
          end

          describe 'uninterruptible job' do
            let(:config) do
              YAML.dump(rspec: { script: 'rspec', interruptible: false })
            end

            it { expect(subject[:interruptible]).to be_falsy }
          end

          it "returns interruptible when overridden for job" do
            config = YAML.dump({ default: { interruptible: true },
                                 rspec: { script: "rspec" } })

            result = Gitlab::Ci::YamlProcessor.new(config).execute

            expect(result.stage_builds_attributes("test").size).to eq(1)
            expect(result.stage_builds_attributes("test").first).to eq({
              stage: "test",
              stage_idx: 2,
              name: "rspec",
              only: { refs: %w[branches tags] },
              options: { script: ["rspec"] },
              interruptible: true,
              allow_failure: false,
              when: "on_success",
              yaml_variables: [],
              scheduling_type: :stage
            })
          end
        end

        describe 'retry entry' do
          context 'when retry count is specified' do
            let(:config) do
              YAML.dump(rspec: { script: 'rspec', retry: { max: 1 } })
            end

            it 'includes retry count in build options attribute' do
              expect(subject[:options]).to include(retry: { max: 1 })
            end
          end

          context 'when retry count is not specified' do
            let(:config) do
              YAML.dump(rspec: { script: 'rspec' })
            end

            it 'does not persist retry count in the database' do
              expect(subject[:options]).not_to have_key(:retry)
            end
          end

          context 'when retry count is specified by default' do
            let(:config) do
              YAML.dump(default: { retry: { max: 1 } },
                        rspec: { script: 'rspec' })
            end

            it 'does use the default value' do
              expect(subject[:options]).to include(retry: { max: 1 })
            end
          end

          context 'when retry count default value is overridden' do
            let(:config) do
              YAML.dump(default: { retry: { max: 1 } },
                        rspec: { script: 'rspec', retry: { max: 2 } })
            end

            it 'does use the job value' do
              expect(subject[:options]).to include(retry: { max: 2 })
            end
          end
        end

        describe 'allow failure entry' do
          context 'when job is a manual action' do
            context 'when allow_failure is defined' do
              let(:config) do
                YAML.dump(rspec: { script: 'rspec',
                                   when: 'manual',
                                   allow_failure: false })
              end

              it 'is not allowed to fail' do
                expect(subject[:allow_failure]).to be false
              end
            end

            context 'when allow_failure is not defined' do
              let(:config) do
                YAML.dump(rspec: { script: 'rspec',
                                   when: 'manual' })
              end

              it 'is allowed to fail' do
                expect(subject[:allow_failure]).to be true
              end
            end
          end

          context 'when job is not a manual action' do
            context 'when allow_failure is defined' do
              let(:config) do
                YAML.dump(rspec: { script: 'rspec',
                                   allow_failure: false })
              end

              it 'is not allowed to fail' do
                expect(subject[:allow_failure]).to be false
              end
            end

            context 'when allow_failure is not defined' do
              let(:config) do
                YAML.dump(rspec: { script: 'rspec' })
              end

              it 'is not allowed to fail' do
                expect(subject[:allow_failure]).to be false
              end
            end
          end
        end

        describe 'delayed job entry' do
          context 'when delayed is defined' do
            let(:config) do
              YAML.dump(rspec: {
                script:   'rollout 10%',
                when:     'delayed',
                start_in: '1 day'
              })
            end

            it 'has the attributes' do
              expect(subject[:when]).to eq 'delayed'
              expect(subject[:options][:start_in]).to eq '1 day'
            end
          end
        end

        describe 'resource group' do
          context 'when resource group is defined' do
            let(:config) do
              YAML.dump(rspec: {
                script:   'test',
                resource_group: 'iOS'
              })
            end

            it 'has the attributes' do
              expect(subject[:resource_group_key]).to eq 'iOS'
            end
          end
        end
      end

    end
  end
end
