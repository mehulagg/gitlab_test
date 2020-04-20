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

    describe 'when updating screenshot path' do
      it 'requires input files to be specified' do
        expect { described_class.invoke('--update-screenshot-path') }
          .to raise_error(OptionParser::MissingArgument, 'missing argument: --update-screenshot-path')
      end

      it 'accepts provided files' do
        update_screenshot_path = double('Gitlab::QA::Report::UpdateScreenshotPath')
        allow(update_screenshot_path).to receive(:invoke!)

        expect(Gitlab::QA::Report::UpdateScreenshotPath).to receive(:new)
                                                         .with(files: 'files')
                                                         .and_return(update_screenshot_path)

        expect { described_class.invoke(%w[--update-screenshot-path files]) }.to raise_error(SystemExit)
      end
    end

    describe 'when posting to slack' do
      context 'without --include-summary-table' do
        it 'requires message to be specified' do
          expect { described_class.invoke('--post-to-slack') }
            .to raise_error(OptionParser::MissingArgument, 'missing argument: --post-to-slack')
        end

        it 'accepts message argument' do
          ClimateControl.modify(CHANNEL: 'abc', SLACK_QA_BOT_TOKEN: 'def') do
            post_to_slack = double('Gitlab::QA::Slack::PostToSlack')

            allow(post_to_slack).to receive(:invoke!)
            allow(Gitlab::QA::Support::HttpRequest).to receive(:make_http_request)

            expect(Gitlab::QA::Slack::PostToSlack).to receive(:new)
                                                        .with(message: 'message')
                                                        .and_return(post_to_slack)

            expect { described_class.invoke(%w[--post-to-slack message]) }.to raise_error(SystemExit)
          end
        end
      end

      context 'with --include-summary-table' do
        it 'requires FILES to be specified' do
          ClimateControl.modify(SLACK_QA_CHANNEL: 'abc', CI_SLACK_WEBHOOK_URL: 'def') do
            expect { described_class.invoke(%w[--post-to-slack message --include-summary-table]) }
              .to raise_error(OptionParser::MissingArgument, 'missing argument: --include-summary-table')
          end
        end

        it 'accepts FILES argument' do
          ClimateControl.modify(SLACK_QA_CHANNEL: 'abc', CI_SLACK_WEBHOOK_URL: 'def') do
            allow(Gitlab::QA::Support::HttpRequest).to receive(:make_http_request)

            expect(Gitlab::QA::Report::SummaryTable).to receive(:create)
                                      .with(input_files: 'FILES')
                                      .and_return('some table')

            expect { described_class.invoke(%w[--post-to-slack message --include-summary-table FILES]) }.to raise_error(SystemExit)
          end
        end
      end
    end

    describe '--include-summary-table' do
      it 'requires to be called with --post-to-slack' do
        expect { described_class.invoke(%w[--include-summary-table FILES]) }
          .to raise_error(RuntimeError, 'This option should be used with --post-to-slack.')
      end
    end
  end
end
