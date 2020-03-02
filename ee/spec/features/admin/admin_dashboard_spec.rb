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

      sign_in(create(:admin))
    end

    context 'for tooltip' do
      before do
        allow(License).to receive(:current).and_return(license)

        visit admin_dashboard_stats_path
      end

      context 'when license is empty' do
        let(:license) { nil }

        it { expect(page).not_to have_css('span.has-tooltip') }
      end

      context 'when license is on a plan Ultimate' do
        let(:license) { create(:license, plan: License::ULTIMATE_PLAN) }

        it { expect(page).to have_css('span.has-tooltip') }
      end

      context 'when license is on a plan other than Ultimate' do
        let(:license) { create(:license, plan: License::PREMIUM_PLAN) }

        it { expect(page).not_to have_css('span.has-tooltip') }
      end
    end

    describe 'Roles stats' do
      it 'shows correct amounts of users per role' do
        visit admin_dashboard_stats_path

        expect(page).to have_content('Users without a Group and Project 1')
        expect(page).to have_content('Users with highest role reporter 1')
        expect(page).to have_content('Users with highest role developer 2')
      end
    end
  end
end
