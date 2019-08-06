# frozen_string_literal: true

require 'spec_helper'

describe 'User edit profile' do
  let(:user) { create(:user) }

  before do
    sign_in(user)
    visit(profile_path)
  end

  def submit_settings
    click_button 'Update profile settings'
    wait_for_requests if respond_to?(:wait_for_requests)
  end

  context 'product improvements', :js do
    def visit_user
      visit user_path(user)
      wait_for_requests
    end

    it 'is enabled by default' do
      field = page.find_field("user[snowplow_tracking]")

      expect(field).to be_checked
    end

    it 'is disabled after save' do
      field = page.find_field("user[snowplow_tracking]")

      field.click
      submit_settings

      expect(field).not_to be_checked
    end
  end
end
