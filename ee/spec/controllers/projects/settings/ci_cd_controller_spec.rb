# frozen_string_literal: true

require('spec_helper')

describe Projects::Settings::CiCdController do
  let_it_be(:user) { create(:user) }
  let(:project) { create(:project) }

  before do
    project.add_maintainer(user)
    sign_in(user)
  end

  describe 'GET show' do
    let(:request) { get :show, params: { namespace_id: project.namespace, project_id: project } }

    it 'logs the audit event' do
      expect { request }.to change { SecurityEvent.count }.by(1)
      expect(SecurityEvent.last.details[:custom_message]).to eq('Accessed CI/CD settings')
    end
  end
end
