describe Gitlab::QA::Runner do
  let(:scenario) { spy('scenario') }
  let(:scenario_arg) { ['Test::Instance::Image'] }
  let(:prepare_reports) { spy('Gitlab::QA::Report::PrepareStageReports') }

  before do
    stub_const('Gitlab::QA::Scenario', scenario)
    stub_const('Gitlab::QA::Report::PrepareStageReports', prepare_reports)
  end

  describe '.run' do
    it 'runs a scenario' do
      described_class.run(scenario_arg)

      expect(scenario).to have_received(:const_get).with('Test::Instance::Image')
    end

    it 'passes args to the scenario' do
      passed_args = %w[CE -- --tag smoke]

      described_class.run(scenario_arg + passed_args)

      expect(scenario).to have_received(:perform).with(*passed_args)
    end

    it 'rejects unsupported options' do
      passed_args = %w[CE --foo]

      expect { described_class.run(scenario_arg + passed_args) }
        .to raise_error(OptionParser::InvalidOption, 'invalid option: --foo')
    end

    context 'with defined options' do
      it 'supports enabling a feature flag' do
        passed_args = %w[CE --enable-feature gitaly_enforce_requests_limits]

        described_class.run(scenario_arg + passed_args)

        expect(scenario).to have_received(:perform).with(*passed_args)
      end

      it 'supports enabling a feature flag with scenarios with no release specified' do
        passed_args = %w[--enable-feature gitaly_enforce_requests_limits]

        described_class.run(['Test::Instance::Staging'] + passed_args)

        expect(scenario).to have_received(:perform).with(*passed_args)
      end

      it 'supports specifying an address' do
        passed_args = %w[CE --address http://testurl]

        described_class.run(scenario_arg + passed_args)

        expect(scenario).to have_received(:perform).with(*passed_args)
      end

      it 'supports specifying a mattermost server address' do
        passed_args = %w[CE --mattermost-address http://mattermost-server]

        described_class.run(scenario_arg + passed_args)

        expect(scenario).to have_received(:perform).with(*passed_args)
      end

      describe 'when preparing stage reports' do
        it 'requires input files to be specified' do
          expect { described_class.run('--prepare-stage-reports') }
            .to raise_error(OptionParser::MissingArgument, 'missing argument: --prepare-stage-reports')
        end

        it 'accepts specified files' do
          files = 'files'

          expect { described_class.run(%w[--prepare-stage-reports files]) }.to raise_error(SystemExit)

          expect(prepare_reports).to have_received(:new).with(input_files: files)
          expect(prepare_reports).to have_received(:invoke!)
        end

        it 'does not run tests' do
          expect { described_class.run(%w[--prepare-stage-reports files]) }.to raise_error(SystemExit)

          expect(scenario).not_to have_received(:perform)
        end
      end
    end
  end
end
