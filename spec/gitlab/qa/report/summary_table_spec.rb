describe Gitlab::QA::Report::SummaryTable do
  describe '#get' do
    it 'requires input files' do
      expect { described_class.create }.to raise_error(ArgumentError, "missing keyword: input_files")
    end

    it 'accepts input files' do
      files = 'files'

      expect(described_class).to receive(:collect_results).with(files).and_return([])

      expect { described_class.create(input_files: files) }.not_to raise_error
    end

    describe 'with input files' do
      it 'returns a summary table of results' do
        input_report1 = '<testsuite name="rspec" tests="2" failures="0" errors="0" skipped="0"/>'
        input_report2 = '<testsuite name="rspec" tests="4" failures="1" errors="1" skipped="1"/>'

        expected_output = <<~OUTPUT
        ```\nDEV STAGE | TOTAL | FAILURES | ERRORS | SKIPPED | RESULT
             ----------|-------|----------|--------|---------|-------
             Plan      | 2     | 0        | 0      | 0       | ✅
             Create    | 4     | 1        | 1      | 1       | ❌
        ```\n
        OUTPUT

        allow(::Dir).to receive(:glob).and_return(%w[plan create])

        expect(::File).to receive(:open).with('plan').and_return(input_report1).ordered
        expect(::File).to receive(:open).with('create').and_return(input_report2).ordered

        expect(described_class.create(input_files: 'files').gsub(/\s+/, "")).to eq expected_output.gsub(/\s+/, "")
      end
    end
  end
end
