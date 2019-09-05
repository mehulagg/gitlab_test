# frozen_string_literal: true

require 'spec_helper'

describe 'Trial Sign Up', :js do
  let(:user_attrs) { attributes_for(:user, first_name: 'GitLab', last_name: 'GitLab') }

  describe 'on GitLab.com' do
    before do
      stub_feature_flags(invisible_captcha: false)
      allow(Gitlab).to receive(:com?).and_return(true).at_least(:once)
    end

    context 'with the unavailable username' do
      let(:existing_user) { create(:user) }

      it 'shows the error about existing username' do
        visit(new_trial_registration_path)
        click_on 'Register'

        within('div#register-pane') do
          fill_in 'user_username', with: existing_user.username
        end

        expect(page).to have_content('Username is already taken.')
      end
    end

    context 'with the available username' do
      it 'registers the user' do
        visit(new_trial_registration_path)
        click_on 'Register'

        within('div#register-pane') do
          fill_in 'user_first_name', with: user_attrs[:first_name]
          fill_in 'user_last_name',  with: user_attrs[:last_name]
          fill_in 'user_username',   with: user_attrs[:username]
          fill_in 'user_email',      with: user_attrs[:email]
          fill_in 'user_password',   with: '12345678'

          check 'terms_opt_in'

          click_button 'Continue'
        end

        user = User.find_by_username!(user_attrs[:username])
        expect(user).not_to be_nil
      end
    end
  end
end
