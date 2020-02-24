# frozen_string_literal: true

require 'spec_helper'

describe Ci::Subscriptions::Project do
  let(:upstream_project) { create(:project, :public) }

  before do
    plan_limits = create(:plan_limits, :default_plan)
    plan_limits.update(ci_project_subscriptions: 2)
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:downstream_project).required }
    it { is_expected.to belong_to(:upstream_project).required }
  end

  describe 'Validations' do
    let!(:subscription) { create(:ci_subscriptions_project, upstream_project: upstream_project) }

    it { is_expected.to validate_uniqueness_of(:upstream_project_id).scoped_to(:downstream_project_id) }

    it 'validates that upstream project is public' do
      upstream_project.update(visibility_level: Gitlab::VisibilityLevel::PRIVATE)

      expect(subscription).not_to be_valid
    end

    it 'validates that project has less than maximum subscriptions' do
      create(:ci_subscriptions_project, upstream_project: upstream_project)
      invalid_subscription = build(:ci_subscriptions_project, upstream_project: upstream_project)

      expect(invalid_subscription).not_to be_valid
    end
  end
end
