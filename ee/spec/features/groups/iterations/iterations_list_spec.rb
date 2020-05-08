# frozen_string_literal: true

require 'spec_helper'

describe 'Iterations list', :js do  
  let(:now) { Time.now }
  let_it_be(:group) { create(:group) }
  # let!(:started_group_sprint) { create(:sprint, :skip_future_date_validation, group: group, title: 'one test', start_date: now - 1.day, due_date: now) }

  # let!(:upcoming_group_sprint) { create(:sprint, group: group, start_date: now + 1.day, due_date: now + 2.days) }

  it 'shows "New iteration" button' do
    visit group_iterations_path(group)
    # todo: check href as well
    live_debug
    expect(page).to have_link('New iteration')
  end

  it 'shows open iterations' do
  end

  it 'shows closed iterations' do
  end

  it 'shows closed iterations' do
  end

  context 'multiple pages' do
    before do
      today = Time.now
      (1..22).each do |i|
        today = (today + 2.days)
        create(:sprint, :skip_future_date_validation, group: group, title: "iteration #{i}", start_date: today, due_date: today + 1.day)
      end
    end

    it 'shows second page of open iterations' do
      visit group_iterations_path(group)

      live_debug

      expect(page).to have_link('Open')
    end
  end
end
