describe Gitlab::QA::Report::UpdateScreenshotPath do
  describe '#invoke!' do
    it 'requires input files' do
      expect { subject.invoke! }.to raise_error(ArgumentError, "missing keyword: files")
    end

    it 'accepts input files' do
      files = 'files'
      subject = described_class.new(files: files)

      allow(::Dir).to receive(:glob).and_return([])

      expect { subject.invoke! }.not_to raise_error
    end

    describe 'with input files' do
      subject { described_class.new(files: 'files') }

      it 'replaces screenshot path' do
        file_path = '/some_path/gitlab-qa-run-2020-04-09-22-54-33-69582143/gitlab-ee-qa-f4399756/rspec-505959567.xml'

        input_system_out = <<~REPORT
          <?xml version="1.0"?>
          <system-out>[[ATTACHMENT|/home/gitlab/qa/tmp/qa-test-2020-04-09-23-02-42-0d1f390c65be6dd7/manage_basic user login.png]]</system-out>
        REPORT

        expected_system_out = <<~REPORT
          <?xml version="1.0"?>
          <system-out>[[ATTACHMENT|gitlab-qa-run-2020-04-09-22-54-33-69582143/gitlab-ee-qa-f4399756/qa-test-2020-04-09-23-02-42-0d1f390c65be6dd7/manage_basic user login.png]]</system-out>
        REPORT

        allow(::Dir).to receive(:glob).and_return([file_path])

        expect(::File).to receive(:open).with(file_path).and_return(input_system_out)
        expect(::File).to receive(:write).with(file_path, expected_system_out)

        expect { subject.invoke! }.to output.to_stdout
      end
    end
  end
end
