require 'spec_helper'

describe OpenProjectService do
  include Gitlab::Routing
  include AssetsHelpers

  describe 'Associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to have_one :service_hook }
  end

  describe 'description and title' do
    let(:project) { create(:project) }
    let(:service) do
      project.create_open_project_service(active: true)
    end

    context 'when it is not set' do
      it 'is initialized' do
        expect(service.title).to eq('Open Project')
        expect(service.description).to eq('Open Project issue tracker')
      end
    end

    context 'when it is set' do
      before do
        # convert string key to symbol
        properties = { title: 'Open Project One', description: 'Open Project One issue tracker' }
        @service = project.create_open_project_service(active: true, properties: properties)
      end

      after do
        @service.destroy!
      end

      it 'is correct' do
        expect(@service.title).to eq('Open Project One')
        expect(@service.description).to eq('Open Project One issue tracker')
      end
    end
  end

  describe 'Validations' do
    let(:project) { create(:project) }

    context 'when service is active' do
      before do
        subject.active = true
      end

      it { is_expected.to validate_presence_of(:url) }
      it_behaves_like 'issue tracker service URL attribute', :url
    end

    context 'when service is inactive' do
      before do
        subject.active = false
      end

      it { is_expected.not_to validate_presence_of(:url) }
      it { is_expected.not_to validate_presence_of(:token) }
    end

    context 'validating urls' do
      let(:service) do
        described_class.new(
          project: project,
          active: true,
          token: 'test',
          closed_status_id: 13,
          url: 'http://gitlab-intergration.openproject.com'
        )
      end

      it 'is valid when all fields have required values' do
        expect(service).to be_valid
      end

      it 'is not valid when url is not a valid url' do
        service.url = 'not valid'

        expect(service).not_to be_valid
      end

      it 'is not valid when api url is not a valid url' do
        service.api_url = 'not valid'

        expect(service).not_to be_valid
      end

      it 'is not valid when token is missing' do
        service.token = nil

        expect(service).not_to be_valid
      end

      it 'is valid when api url is a valid url' do
        service.api_url = 'http://gitlab-intergration.openproject.com/api'

        expect(service).to be_valid
      end
    end
  end

  describe '.reference_pattern' do
    it_behaves_like 'allows project key on reference pattern'

    it 'does not allow # on the code' do
      expect(described_class.reference_pattern.match('#123')).to be_nil
      expect(described_class.reference_pattern.match('1#23#12')).to be_nil
    end
  end

  describe 'project and issue urls' do
    let(:project) { create(:project) }

    context 'when gitlab.yml was initialized' do
      before do
        settings = {
            'open_project' => {
                'title' => 'Open Project',
                'url' => 'http://openProject.sample/projects/project_a',
                'api_url' => 'http://openProject.sample/api',
                'token' => 'test'
            }
        }
        allow(Gitlab.config).to receive(:issues_tracker).and_return(settings)
        @service = project.create_open_project_service(active: true)
      end

      after do
        @service.destroy!
      end

      it 'is prepopulated with the settings' do
        expect(@service.properties['title']).to eq('Open Project')
        expect(@service.properties['url']).to eq('http://openProject.sample/projects/project_a')
        expect(@service.properties['api_url']).to eq('http://openProject.sample/api')
      end
    end
  end
end
