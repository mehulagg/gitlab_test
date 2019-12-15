# frozen_string_literal: true

require('spec_helper')

describe Groups::Settings::CiCdController do
  let_it_be(:user) { create(:user) }
  let(:group) { create(:group) }

  before do
    group.add_owner(user)
    sign_in(user)
  end

  describe 'GET show' do
    let(:request) { get :show, params: { group_id: group } }

    it 'logs the audit event' do
      expect { request }.to change { SecurityEvent.count }.by(1)
      expect(SecurityEvent.last.details[:custom_message]).to eq('Accessed CI/CD settings')
    end
  end
end
