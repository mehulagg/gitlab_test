# frozen_string_literal: true

require 'spec_helper'

describe SeatsMonitoringHelper do
  let_it_be(:admin) { create(:admin) }
  let_it_be(:user) { create(:user) }
  let_it_be(:license_starts_at) { Date.parse('2020-01-01') }
  let_it_be(:license_expires_at) { Date.parse('2020-12-31') }
  let_it_be(:end_of_first_quarter) { Date.parse('2020-04-01') }
  let_it_be(:end_of_second_quarter) { Date.parse('2020-07-01') }
  let_it_be(:license_seats_limit) { 10 }
  let_it_be(:license) do
    License.destroy_all # rubocop: disable DestroyAll

    create(:license,
           created_at: license_starts_at,
           data: build(:gitlab_license,
                       starts_at: license_starts_at,
                       expires_at: license_expires_at,
                       restrictions: {active_user_count: license_seats_limit}
           ).export
    )
  end

  shared_examples_for "rendered banner" do
    it 'renders the overage banner' do
      Timecop.freeze(custom_date) do
        expect(helper.display_license_overage_warning?).to eq(true)
      end
    end
  end

  shared_examples_for "not rendered banner" do
    it 'does not render the overage banner' do
      Timecop.freeze(custom_date) do
        expect(helper.display_license_overage_warning?).to eq(false)
      end
    end
  end

  context 'when admin is logged in' do
    before do
      allow(helper).to receive(:current_user).and_return(admin)
    end

    context 'when license is above the threshold' do
      before do
        HistoricalData.create!(date: license_starts_at, active_user_count: license_seats_limit + 5)
      end

      context 'one week before the end of period' do
        it_behaves_like 'rendered banner' do
          let(:custom_date) { 6.days.ago(end_of_first_quarter) }
        end
      end

      context 'two weeks before the end of period' do
        it_behaves_like 'not rendered banner' do
          let(:custom_date) { 10.days.ago(end_of_first_quarter) }
        end
      end
    end

    context 'when the overage belongs to a different period' do
      before do
        HistoricalData.create!(date: 3.days.ago(end_of_first_quarter), active_user_count: license_seats_limit + 5)
      end

      context 'one week before the end of period' do
        it_behaves_like 'not rendered banner' do
          let(:custom_date) { 5.days.ago(end_of_second_quarter) }
        end
      end
    end

    context 'when license is under the threshold' do
      before do
        HistoricalData.create!(date: license_starts_at, active_user_count: license_seats_limit)
      end

      context 'one week before the end of period' do
        it_behaves_like 'not rendered banner' do
          let(:custom_date) { 6.days.ago(end_of_first_quarter) }
        end
      end

      context 'two weeks before the end of period' do
        it_behaves_like 'not rendered banner' do
          let(:custom_date) { 10.days.ago(end_of_first_quarter) }
        end
      end
    end
  end

  context 'when regular user is logged in' do
    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'when license is above the threshold' do
      before do
        HistoricalData.create!(date: license_starts_at, active_user_count: license_seats_limit + 5)
      end

      context 'one week before the end of period' do
        it_behaves_like 'not rendered banner' do
          let(:custom_date) { 6.days.ago(end_of_first_quarter) }
        end
      end
    end
  end
end
