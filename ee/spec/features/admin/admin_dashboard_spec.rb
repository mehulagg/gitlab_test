# frozen_string_literal: true

require 'spec_helper'

describe 'Admin Dashboard' do
  describe 'Users statistic' do
    before do
      project1 = create(:project_empty_repo)
      project1.add_reporter(create(:user))

      project2 = create(:project_empty_repo)
      project2.add_developer(create(:user))

      # Add same user as Reporter and Developer to different projects
      # and expect it to be counted once for the stats
      user = create(:user)
      project1.add_reporter(user)
      project2.add_developer(user)

      blocked_user = create(:user, :blocked)
      project1.add_maintainer(blocked_user)

      sign_in(create(:admin))
    end

    describe 'Roles stats' do
      it 'shows correct amount for user counts' do
        visit admin_dashboard_stats_path

        expect(page).to have_content('Admin users 1')
        expect(page).to have_content('Users without a Group and Project 1')
        expect(page).to have_content('Users with highest role reporter 1')
        expect(page).to have_content('Users with highest role developer 2')
        expect(page).to have_content('Blocked users 1')
        expect(page).to have_content('Total users 7')
      end

      context 'when active users count' do
        before do
          allow(License).to receive(:current).and_return(license)

          visit admin_dashboard_stats_path
        end

        context 'when license is empty' do
          let(:license) { nil }

          it 'does not show a clarification on active users' do
            expect(page).to have_content('Active users 6')
          end
        end

        context 'when license is on a paid plan' do
          let(:license) { create(:license, plan: License::ULTIMATE_PLAN) }

          it 'shows a clarification on active users' do
            expect(page).to have_content('Active users (Billable users) 6')
          end
        end

        context 'when license is not on a paid plan' do
          let(:license) { create(:license, plan: 'unknown') }

          it 'does not show a clarification on active users' do
            expect(page).to have_content('Active users 6')
          end
        end
      end
    end
  end
end
