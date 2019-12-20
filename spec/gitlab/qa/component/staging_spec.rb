describe Gitlab::QA::Component::Staging do
  around do |example|
    ClimateControl.modify(
      GITLAB_QA_ACCESS_TOKEN: 'abc123',
      GITLAB_QA_DEV_ACCESS_TOKEN: 'abc123') { example.run }
  end

  describe Gitlab::QA::Component::Staging::Version do
    subject { described_class.new('https://dev.gitlab.org') }

    let(:version_api_url) { "https://dev.gitlab.org/api/v4/version" }

    def api_response(version)
      { body: { 'version': version, 'revision': '20920f8074a' }.to_json }
    end

    describe '#tag_end' do
      context 'when it is an auto-deploy release' do
        it 'retrieves the revision from the version API' do
          request = stub_request(:get, version_api_url).to_return(api_response('12.3.0-pre')).times(1)
          expect(subject.tag_end).to eq('20920f8074a')
          expect(request).to have_been_requested
        end
      end

      context 'when it is an official release' do
        it 'retrieves the version from the version API' do
          request = stub_request(:get, version_api_url).to_return(api_response('12.3.0-ee')).times(1)
          expect(subject.tag_end).to eq('12.3.0-ee')
          expect(request).to have_been_requested
        end
      end

      context 'when it is an RC release' do
        it 'retrieves the version from the version API' do
          request = stub_request(:get, version_api_url).to_return(api_response('12.6.0-rc42-ee')).times(1)
          expect(subject.tag_end).to eq('12.6.0-rc42-ee')
          expect(request).to have_been_requested
        end
      end
    end

    describe '#major_minor_revision' do
      it 'return minor and major version components plus revision' do
        request = stub_request(:get, version_api_url).to_return(api_response('12.3.0-pre')).times(1)
        expect(subject.major_minor_revision).to eq('12.3-20920f8074a')
        expect(request).to have_been_requested
      end
    end
  end
end
