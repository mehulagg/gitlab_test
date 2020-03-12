describe Gitlab::QA::Reporter do
  describe '.invoke' do
    describe 'when preparing stage reports' do
      it 'requires input files to be specified' do
        expect { described_class.invoke('--prepare-stage-reports') }
          .to raise_error(OptionParser::MissingArgument, 'missing argument: --prepare-stage-reports')
      end

      it 'accepts specified files' do
        prepare_reports = double('Gitlab::QA::Report::PrepareStageReports')
        allow(prepare_reports).to receive(:invoke!)

        expect(Gitlab::QA::Report::PrepareStageReports).to receive(:new)
          .with(input_files: 'files')
          .and_return(prepare_reports)

        expect { described_class.invoke(%w[--prepare-stage-reports files]) }.to raise_error(SystemExit)
      end
    end

    describe 'when reporting in issues' do
      it 'requires input files to be specified' do
        expect { described_class.invoke('--report-in-issues') }
          .to raise_error(OptionParser::MissingArgument, 'missing argument: --report-in-issues')
      end

      it 'accepts provided files, token, and project' do
        report_in_issues = double('Gitlab::QA::Report::ReportInIssues')
        allow(report_in_issues).to receive(:invoke!)

        expect(Gitlab::QA::Report::ResultsInIssues).to receive(:new)
          .with(input_files: 'files', token: 'token', project: 'project')
          .and_return(report_in_issues)

        expect { described_class.invoke(%w[--report-in-issues files -t token -p project]) }.to raise_error(SystemExit)
      end
    end
  end
end
