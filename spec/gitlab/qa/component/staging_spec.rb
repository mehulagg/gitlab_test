describe Gitlab::QA::Component::Staging do
  around do |example|
    ClimateControl.modify(
      GITLAB_QA_ACCESS_TOKEN: 'abc123',
      GITLAB_QA_DEV_ACCESS_TOKEN: 'abc123') { example.run }
  end

  describe Gitlab::QA::Component::Staging::Version do
    subject { described_class.new('https://dev.gitlab.org') }

    let(:version_api_url) { "https://dev.gitlab.org/api/v4/version" }
    let(:response) do
      { body: { 'version': '12.3.0-pre', 'revision': '20920f8074a' }.to_json }
    end
    let!(:request_stub) do
      stub_request(:get, version_api_url).to_return(response).times(1)
    end

    describe '#revision' do
      it 'retrieves the revision from the version API' do
        expect(subject.revision).to eq('20920f8074a')
        expect(request_stub).to have_been_requested
      end
    end

    describe '#major_minor_revision' do
      it 'return minor and major version components plus revision' do
        expect(subject.major_minor_revision).to eq('12.3-20920f8074a')
        expect(request_stub).to have_been_requested
      end
    end
  end
end
