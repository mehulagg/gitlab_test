describe Gitlab::QA::Report::PrepareStageReports do
  describe '#invoke!' do
    it 'requires input files' do
      expect { subject.invoke! }.to raise_error(ArgumentError, "missing keyword: input_files")
    end

    it 'accepts input files' do
      files = 'files'
      subject = described_class.new(input_files: files)

      expect(subject).to receive(:collate_test_cases).with(files).and_return([])

      expect { subject.invoke! }.not_to raise_error
    end

    describe 'with input files' do
      subject { described_class.new(input_files: 'files') }

      it 'collects test cases of the same stage from separate files' do
        input_report1 = <<~REPORT
          <?xml version="1.0"?>
          <testsuite name="rspec" tests="2" failures="0" errors="0" skipped="0">
            <testcase file="api/stage1/file"/>
            <testcase file="api/stage2/file"/>
          </testsuite>
        REPORT
        input_report2 = <<~REPORT
          <?xml version="1.0"?>
          <testsuite name="rspec" tests="2" failures="0" errors="0" skipped="0">
            <testcase file="browser_ui/stage1/file"/>
            <testcase file="browser_ui/stage2/file"/>
          </testsuite>
        REPORT
        expected_report1 = <<~REPORT
          <?xml version="1.0"?>
          <testsuite name="rspec" tests="2" failures="0" errors="0" skipped="0">
            <testcase file="api/stage1/file"/>
            <testcase file="browser_ui/stage1/file"/>
          </testsuite>
        REPORT
        expected_report2 = <<~REPORT
          <?xml version="1.0"?>
          <testsuite name="rspec" tests="2" failures="0" errors="0" skipped="0">
            <testcase file="api/stage2/file"/>
            <testcase file="browser_ui/stage2/file"/>
          </testsuite>
        REPORT

        allow(::Dir).to receive(:glob).and_return(%w[file1 file2])

        expect(::File).to receive(:open).with('file1').and_return(input_report1).ordered
        expect(::File).to receive(:open).with('file2').and_return(input_report2).ordered
        expect(::File).to receive(:write).with('stage1.xml', expected_report1).ordered
        expect(::File).to receive(:write).with('stage2.xml', expected_report2).ordered

        expect { subject.invoke! }.to output.to_stdout
      end

      it 'strips `x_` from the start of stages in file paths' do
        allow(::Dir).to receive(:glob).and_return(%w[file1 file2 file3 file4])

        expect(::File).to receive(:open).with('file1').and_return('<testcase file="api/1_stage/file"/>').ordered
        expect(::File).to receive(:open).with('file2').and_return('<testcase file="api/01_another_stage/file"/>').ordered
        expect(::File).to receive(:open).with('file3').and_return('<testcase file="api/_stage/file"/>').ordered
        expect(::File).to receive(:open).with('file4').and_return('<testcase file="api/stage_1/file"/>').ordered
        expect(::File).to receive(:write).with('stage.xml', anything).ordered
        expect(::File).to receive(:write).with('another_stage.xml', anything).ordered
        expect(::File).to receive(:write).with('_stage.xml', anything).ordered
        expect(::File).to receive(:write).with('stage_1.xml', anything).ordered

        expect { subject.invoke! }.to output.to_stdout
      end

      it 'counts failures, errors, and skipped tests' do
        input_report1 = <<~REPORT
          <?xml version="1.0"?>
          <testsuite name="rspec" tests="5" failures="2" errors="0" skipped="2">
            <testcase file="api/stage/file1">
              <failure/>
            </testcase>
            <testcase file="api/stage/file2">
              <failure/>
            </testcase>
            <testcase file="api/stage/file4">
              <skipped/>
            </testcase>
            <testcase file="api/stage/file5">
              <skipped/>
            </testcase>
            <testcase file="api/stage/file6"/>
          </testsuite>
        REPORT
        input_report2 = <<~REPORT
          <?xml version="1.0"?>
          <testsuite name="rspec" tests="4" failures="1" errors="1" skipped="1">
            <testcase file="api/stage/file7">
              <failure/>
            </testcase>
            <testcase file="api/stage/file8">
              <error/>
            </testcase>
            <testcase file="api/stage/file9">
              <skipped/>
            </testcase>
            <testcase file="api/stage/file10"/>
          </testsuite>
        REPORT
        expected_report = <<~REPORT
          <?xml version="1.0"?>
          <testsuite name="rspec" tests="9" failures="3" errors="1" skipped="3">
            <testcase file="api/stage/file1">
              <failure/>
            </testcase>
            <testcase file="api/stage/file2">
              <failure/>
            </testcase>
            <testcase file="api/stage/file4">
              <skipped/>
            </testcase>
            <testcase file="api/stage/file5">
              <skipped/>
            </testcase>
            <testcase file="api/stage/file6"/>
            <testcase file="api/stage/file7">
              <failure/>
            </testcase>
            <testcase file="api/stage/file8">
              <error/>
            </testcase>
            <testcase file="api/stage/file9">
              <skipped/>
            </testcase>
            <testcase file="api/stage/file10"/>
          </testsuite>
        REPORT

        allow(::Dir).to receive(:glob).and_return(%w[file1 file2])

        expect(::File).to receive(:open).with('file1').and_return(input_report1).ordered
        expect(::File).to receive(:open).with('file2').and_return(input_report2).ordered
        expect(::File).to receive(:write).with('stage.xml', expected_report).ordered

        expect { subject.invoke! }.to output.to_stdout
      end
    end
  end
end
