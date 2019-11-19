require 'spec_helper'

describe Gitlab::GitlabImport::Importer do
  include ImportSpecHelper

  describe '#execute' do
    before do
      stub_omniauth_provider('gitlab')
      stub_request('issues', [
        {
          'id' => 2579857,
          'iid' => 3,
          'title' => 'Issue',
          'description' => 'Lorem ipsum',
          'state' => 'opened',
          'confidential' => true,
          'author' => {
            'id' => 283999,
            'name' => 'John Doe'
          }
        },
        {
          'id' => 2579858,
          'iid' => 4,
          'title' => 'Issue',
          'description' => 'Dolum Amet',
          'state' => 'closed',
          'confidential' => false,
          'author' => {
            'id' => 283999,
            'name' => 'John Doe'
          }
        }
      ])
      stub_request('issues/3/notes', [])
      stub_request('issues/4/notes', [])
    end

    it 'persists issues with correct attributes' do
      project = create(:project, import_source: 'asd/vim')
      project.build_import_data(credentials: { password: 'password' })
      subject = described_class.new(project)
      issue_1_expected_attributes = {
        iid: 3,
        title: 'Issue',
        description: "*Created by: John Doe*\n\nLorem ipsum",
        state: 'opened',
        confidential: true,
        author_id: project.creator_id
      }
      issue_2_expected_attributes = {
        iid: 4,
        title: 'Issue',
        description: "*Created by: John Doe*\n\nDolum Amet",
        state: 'closed',
        confidential: false,
        author_id: project.creator_id
      }

      subject.execute

      [issue_1_expected_attributes, issue_2_expected_attributes].each do |expected_attributes|
        issue = project.issues.find_by_iid(expected_attributes[:iid])
        expect(issue).to have_attributes(expected_attributes)
      end
    end

    def stub_request(path, body)
      url = "https://gitlab.com/api/v4/projects/asd%2Fvim/#{path}?page=1&per_page=100"

      WebMock.stub_request(:get, url)
        .to_return(
          headers: { 'Content-Type' => 'application/json' },
          body: body
        )
    end
  end
end
