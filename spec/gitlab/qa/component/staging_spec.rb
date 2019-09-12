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

  describe Gitlab::QA::Component::Staging::DevEEQAImage do
    describe '#retrieve_image_from_container_registry!' do
      let(:container_tags_api_url) { "https://dev.gitlab.org/api/v4/projects/gitlab%2Fomnibus-gitlab/registry/repositories/#{described_class::GITLAB_EE_QA_REPOSITORY_ID}/tags" }
      let(:page1_response) do
        {
          body: [{
            'name': '12.2-0874a8d346c',
            'path': 'gitlab/omnibus-gitlab/gitlab-ee-qa:12.2-0874a8d346c',
            'location': 'dev.gitlab.org:5005/gitlab/omnibus-gitlab/gitlab-ee-qa:12.2-0874a8d346c'
          }].to_json,
          headers: { 'x-next-page': '2' }
        }
      end
      let(:page2_response) do
        {
          body: [{
            'name': '12.2-0c1c17abba9',
            'path': 'gitlab/omnibus-gitlab/gitlab-ee-qa:12.2-0c1c17abba9',
            'location': 'dev.gitlab.org:5005/gitlab/omnibus-gitlab/gitlab-ee-qa:12.2-0c1c17abba9'
          }].to_json,
          headers: { 'x-next-page': '' }
        }
      end
      let!(:page1_request_stub) do
        stub_request(:get, container_tags_api_url)
          .with(query: { 'per_page' => '100' })
          .to_return(page1_response).times(1)
      end
      let!(:page2_request_stub) do
        stub_request(:get, container_tags_api_url)
          .with(query: { 'per_page' => '100', 'page' => '2' })
          .to_return(page2_response).times(1)
      end

      shared_examples 'QA image exists' do
        it 'returns a QA image' do
          expect(subject.retrieve_image_from_container_registry!(revision_needle)).to eq(expected_image)
        end
      end

      context 'when image is found in the first page' do
        let(:revision_needle) { '0874a8d346c' }

        it_behaves_like 'QA image exists' do
          let(:expected_image) { 'dev.gitlab.org:5005/gitlab/omnibus-gitlab/gitlab-ee-qa:12.2-0874a8d346c' }
        end

        it 'makes the expected requests' do
          subject.retrieve_image_from_container_registry!(revision_needle)

          expect(page1_request_stub).to have_been_requested
        end
      end

      context 'when image is found in the second/last page' do
        let(:revision_needle) { '0c1c17abba9' }

        it_behaves_like 'QA image exists' do
          let(:expected_image) { 'dev.gitlab.org:5005/gitlab/omnibus-gitlab/gitlab-ee-qa:12.2-0c1c17abba9' }
        end

        it 'makes the expected requests' do
          subject.retrieve_image_from_container_registry!(revision_needle)

          expect(page1_request_stub).to have_been_requested
          expect(page2_request_stub).to have_been_requested
        end
      end

      context 'when image is not found' do
        let(:revision_needle) { 'foo' }

        it 'raises a QAImageNotFoundError error' do
          expect { subject.retrieve_image_from_container_registry!(revision_needle) }
            .to raise_error(described_class::QAImageNotFoundError, "No `gitlab-ee-qa` image could be found for the revision `foo`.")
        end
      end
    end
  end
end
