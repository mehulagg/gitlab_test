# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'trials/_skip_trial.html.haml' do
  include ApplicationHelper

  let(:source) { nil }
  let(:group_only_trials_exp_active) { false }
  let(:data_track_event) { '[data-track-event="skip_trial"]' }

  before do
    allow(view).to receive(:experiment_tracking_category_and_group).and_return('category:group')
    stub_experiment(group_only_trials: group_only_trials_exp_active)
    params[:glm_source] = source if source
    render 'trials/skip_trial'
  end

  subject { rendered }

  shared_examples 'has Skip Trial verbiage' do
    it { is_expected.to have_content("Skip Trial (Continue with Free Account)") }
  end

  shared_examples 'has tracking data' do
    it { is_expected.to have_selector(data_track_event) }
  end

  shared_examples 'has no tracking data' do
    it { is_expected.not_to have_selector(data_track_event) }
  end

  context 'without glm_source' do
    include_examples 'has Skip Trial verbiage'
    include_examples 'has no tracking data'

    context 'when the group-only trials experiment is active' do
      let(:group_only_trials_exp_active) { true }

      include_examples 'has tracking data'
    end
  end

  context 'with glm_source of about.gitlab.com' do
    let(:source) { 'about.gitlab.com' }

    include_examples 'has Skip Trial verbiage'
    include_examples 'has no tracking data'

    context 'when the group-only trials experiment is active' do
      let(:group_only_trials_exp_active) { true }

      include_examples 'has tracking data'
    end
  end

  context 'with glm_source of gitlab.com' do
    let(:source) { 'gitlab.com' }

    it { is_expected.to have_content("Go back to GitLab") }

    include_examples 'has no tracking data'

    context 'when the group-only trials experiment is active' do
      let(:group_only_trials_exp_active) { true }

      include_examples 'has tracking data'
    end
  end
end
