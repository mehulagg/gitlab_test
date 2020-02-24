# frozen_string_literal: true

require 'spec_helper'

describe 'Admin Mode Login', :clean_gitlab_redis_shared_state, :do_not_mock_admin_mode do
  include TermsHelper
  include UserLoginHelper

  describe 'with two-factor authentication', :js do
    def enter_code(code)
      fill_in 'user_otp_attempt', with: code
      click_button 'Verify code'
    end

    context 'with valid username/password' do
      let(:user) { create(:admin, :two_factor) }

      before do
        gitlab_sign_in(user, remember: true)

        expect(page).to have_content('Two-Factor Authentication')

        enter_code(user.current_otp)
        gitlab_enable_admin_mode_sign_in(user)

        expect(page).to have_content('Two-Factor Authentication')
      end

      context 'using one-time code' do
        it 'blocks login if we reuse the same code immediately' do
          enter_code(user.current_otp)

          expect(page).to have_content('Invalid two-factor code')
        end

        it 'allows login with valid code' do
          # Cannot reuse the TOTP
          Timecop.travel(30.seconds.from_now) do
            enter_code(user.current_otp)

            expect(current_path).to eq admin_root_path
            expect(page).to have_content('Admin mode enabled')
          end
        end

        it 'blocks login with invalid code' do
          # Cannot reuse the TOTP
          Timecop.travel(30.seconds.from_now) do
            enter_code('foo')

            expect(page).to have_content('Invalid two-factor code')
          end
        end

        it 'allows login with invalid code, then valid code' do
          # Cannot reuse the TOTP
          Timecop.travel(30.seconds.from_now) do
            enter_code('foo')

            expect(page).to have_content('Invalid two-factor code')

            enter_code(user.current_otp)

            expect(current_path).to eq admin_root_path
            expect(page).to have_content('Admin mode enabled')
          end
        end
      end

      context 'using backup code' do
        let(:codes) { user.generate_otp_backup_codes! }

        before do
          expect(codes.size).to eq 10

          # Ensure the generated codes get saved
          user.save
        end

        context 'with valid code' do
          it 'allows login' do
            enter_code(codes.sample)

            expect(current_path).to eq admin_root_path
            expect(page).to have_content('Admin mode enabled')
          end

          it 'invalidates the used code' do
            expect { enter_code(codes.sample) }
              .to change { user.reload.otp_backup_codes.size }.by(-1)
          end
        end

        context 'with invalid code' do
          it 'blocks login' do
            code = codes.sample
            expect(user.invalidate_otp_backup_code!(code)).to eq true

            user.save!
            expect(user.reload.otp_backup_codes.size).to eq 9

            enter_code(code)

            expect(page).to have_content('Invalid two-factor code.')
          end
        end
      end
    end
  end
end
