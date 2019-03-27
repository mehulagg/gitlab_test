# frozen_string_literal: true

require 'spec_helper'

describe 'SAML access enforcement' do
  let(:user) { create(:user) }
  let(:group) { create(:group, :private) }
  let(:saml_provider) { create(:saml_provider, group: group, enforced_sso: true) }

  before do
    group.add_guest(user)
    sign_in(user)
  end

  context 'without SAML session' do
    it 'prevents access to group resources' do
      visit group_path(group)

      expect(current_path).to eq(new_user_session_path)
    end
  end

  context 'with active SAML session' do
    let(:session) { page.driver.browser.current_session.instance_variable_get(:"@rack_mock_session").last_request.env["rack.session"] } #TODO: alternate approach
    let(:enforcer) { Gitlab::Auth::GroupSaml::SessionEnforcer.new(session, saml_provider) }

    before do
      visit '/' #Ensures last_request
      enforcer.update_session
    end

    it 'allows access to group resources' do
      visit group_path(group)

      expect(current_path).to eq(group_path(group))
    end
  end
end
