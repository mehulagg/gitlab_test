require 'spec_helper'

describe Namespace do
  let!(:namespace) { create(:namespace) }
  let!(:free_plan) { create(:free_plan) }
  let!(:bronze_plan) { create(:bronze_plan) }
  let!(:silver_plan) { create(:silver_plan) }
  let!(:gold_plan) { create(:gold_plan) }

  it { is_expected.to have_one(:namespace_statistics) }
  it { is_expected.to have_one(:gitlab_subscription).dependent(:destroy) }
  it { is_expected.to belong_to(:plan) }

  it { is_expected.to delegate_method(:shared_runners_minutes).to(:namespace_statistics) }
  it { is_expected.to delegate_method(:shared_runners_seconds).to(:namespace_statistics) }
  it { is_expected.to delegate_method(:shared_runners_seconds_last_reset).to(:namespace_statistics) }
  it { is_expected.to delegate_method(:trial?).to(:gitlab_subscription) }
  it { is_expected.to delegate_method(:trial_ends_on).to(:gitlab_subscription) }

  context 'scopes' do
    describe '.with_plan' do
      let!(:namespace) { create :namespace, plan: namespace_plan }

      context 'plan is set' do
        let(:namespace_plan) { :bronze_plan }

        it 'returns namespaces with plan' do
          expect(described_class.with_plan).to eq([namespace])
        end
      end

      context 'plan is not set' do
        context 'plan is empty string' do
          let(:namespace_plan) { '' }

          it 'returns no namespace' do
            expect(described_class.with_plan).to be_empty
          end
        end

        context 'plan is nil' do
          let(:namespace_plan) { nil }

          it 'returns no namespace' do
            expect(described_class.with_plan).to be_empty
          end
        end
      end
    end
  end

  describe 'custom validations' do
    describe '#validate_plan_name' do
      let(:group) { build(:group) }

      context 'with a valid plan name' do
        it 'is valid' do
          group.plan = create(:bronze_plan)

          expect(group).to be_valid
        end
      end

      context 'with an invalid plan name' do
        it 'is invalid' do
          group.plan = 'unknown'

          expect(group).not_to be_valid
          expect(group.errors[:plan]).to include('is not included in the list')
        end
      end
    end

    describe '#validate_shared_runner_minutes_support' do
      before do
        stub_feature_flags(shared_runner_minutes_on_root_namespace: true)
      end

      context 'when changing :shared_runners_minutes_limit' do
        before do
          namespace.shared_runners_minutes_limit = 100
        end

        context 'when group is subgroup' do
          set(:root_ancestor) { create(:group) }
          let(:namespace) { create(:namespace, parent: root_ancestor) }

          it 'is invalid' do
            expect(namespace).not_to be_valid
            expect(namespace.errors[:shared_runners_minutes_limit]).to include('is not supported for this namespace')
          end
        end

        context 'when group is root' do
          it 'is valid' do
            expect(namespace).to be_valid
          end
        end
      end
    end
  end

  describe '#move_dir' do
    context 'when running on a primary node' do
      set(:primary) { create(:geo_node, :primary) }
      set(:secondary) { create(:geo_node) }
      let(:gitlab_shell) { Gitlab::Shell.new }
      let(:parent_group) { create(:group) }
      let(:child_group) { create(:group, name: 'child', path: 'child', parent: parent_group) }
      let!(:project_legacy) { create(:project_empty_repo, :legacy_storage, namespace: parent_group) }
      let!(:project_child_hashed) { create(:project, namespace: child_group) }
      let!(:project_child_legacy) { create(:project_empty_repo, :legacy_storage, namespace: child_group) }
      let!(:full_path_was) { "#{parent_group.full_path}_old" }

      before do
        new_path = parent_group.full_path

        allow(parent_group).to receive(:gitlab_shell).and_return(gitlab_shell)
        allow(parent_group).to receive(:path_changed?).and_return(true)
        allow(parent_group).to receive(:full_path_was).and_return(full_path_was)
        allow(parent_group).to receive(:full_path).and_return(new_path)

        allow(gitlab_shell).to receive(:mv_namespace)
          .with(project_legacy.repository_storage, full_path_was, new_path)
          .and_return(true)
      end

      it 'logs the Geo::RepositoryRenamedEvent for each project inside namespace' do
        expect { parent_group.move_dir }.to change(Geo::RepositoryRenamedEvent, :count).by(3)
      end

      it 'properly builds old_path_with_namespace' do
        parent_group.move_dir

        actual = Geo::RepositoryRenamedEvent.last(3).map(&:old_path_with_namespace)
        expected = %W[
          #{full_path_was}/#{project_legacy.path}
          #{full_path_was}/child/#{project_child_hashed.path}
          #{full_path_was}/child/#{project_child_legacy.path}
        ]

        expect(actual).to match_array(expected)
      end
    end
  end

  describe '#feature_available?' do
    let(:hosted_plan) { create(:bronze_plan) }
    let(:group) { create(:group) }
    let(:feature) { :service_desk }

    subject { group.feature_available?(feature) }

    before do
      create(:gitlab_subscription, namespace: group, hosted_plan: hosted_plan)

      stub_licensed_features(feature => true)
    end

    it 'uses the global setting when running on premise' do
      stub_application_setting_on_object(group, should_check_namespace_plan: false)

      is_expected.to be_truthy
    end

    it 'only checks the plan once' do
      expect(group).to receive(:load_feature_available).once.and_call_original

      2.times { group.feature_available?(:service_desk) }
    end

    context 'when checking namespace plan' do
      before do
        stub_application_setting_on_object(group, should_check_namespace_plan: true)
      end

      it 'combines the global setting with the group setting when not running on premise' do
        is_expected.to be_falsy
      end

      context 'when feature available on the plan' do
        let(:hosted_plan) { create(:gold_plan) }

        context 'when feature available for current group' do
          it 'returns true' do
            is_expected.to be_truthy
          end
        end

        if Group.supports_nested_objects?
          context 'when license is applied to parent group' do
            let(:child_group) { create :group, parent: group }

            it 'child group has feature available' do
              expect(child_group.feature_available?(feature)).to be_truthy
            end
          end
        end
      end

      context 'when feature not available in the plan' do
        let(:feature) { :deploy_board }
        let(:hosted_plan) { create(:bronze_plan) }

        it 'returns false' do
          is_expected.to be_falsy
        end
      end
    end

    context 'when feature is disabled by a feature flag' do
      it 'returns false' do
        stub_feature_flags(feature => false)

        is_expected.to eq(false)
      end
    end

    context 'when feature is enabled by a feature flag' do
      it 'returns true' do
        stub_feature_flags(feature => true)

        is_expected.to eq(true)
      end
    end
  end

  describe '#max_active_pipelines' do
    context 'when there is no limit defined' do
      it 'returns zero' do
        expect(namespace.max_active_pipelines).to be_zero
      end
    end

    context 'when free plan has limit defined' do
      before do
        free_plan.update_column(:active_pipelines_limit, 40)
      end

      it 'returns a free plan limits' do
        expect(namespace.max_active_pipelines).to be 40
      end
    end

    context 'when associated plan has no limit defined' do
      before do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan)
      end

      it 'returns zero' do
        expect(namespace.max_active_pipelines).to be_zero
      end
    end

    context 'when limit is defined' do
      before do
        gold_plan.update_column(:active_pipelines_limit, 10)
        create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan)
      end

      it 'returns a number of maximum active pipelines' do
        expect(namespace.max_active_pipelines).to eq 10
      end
    end
  end

  describe '#max_pipeline_size' do
    context 'when there are no limits defined' do
      it 'returns zero' do
        expect(namespace.max_pipeline_size).to be_zero
      end
    end

    context 'when free plan has limit defined' do
      before do
        free_plan.update_column(:pipeline_size_limit, 40)
      end

      it 'returns a free plan limits' do
        expect(namespace.max_pipeline_size).to be 40
      end
    end

    context 'when associated plan has no limits defined' do
      before do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan)
      end

      it 'returns zero' do
        expect(namespace.max_pipeline_size).to be_zero
      end
    end

    context 'when limit is defined' do
      before do
        gold_plan.update_column(:pipeline_size_limit, 15)
        create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan)
      end

      it 'returns a number of maximum pipeline size' do
        expect(namespace.max_pipeline_size).to eq 15
      end
    end
  end

  describe '#shared_runners_enabled?' do
    subject { namespace.shared_runners_enabled? }

    context 'without projects' do
      it { is_expected.to be_falsey }
    end

    context 'with project' do
      context 'and disabled shared runners' do
        let!(:project) do
          create(:project,
            namespace: namespace,
            shared_runners_enabled: false)
        end

        it { is_expected.to be_falsey }
      end

      context 'and enabled shared runners' do
        let!(:project) do
          create(:project,
            namespace: namespace,
            shared_runners_enabled: true)
        end

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#actual_shared_runners_minutes_limit' do
    subject { namespace.actual_shared_runners_minutes_limit }

    context 'when no limit defined' do
      it { is_expected.to be_zero }
    end

    context 'when application settings limit is set' do
      before do
        stub_application_setting(shared_runners_minutes: 1000)
      end

      it 'returns global limit' do
        is_expected.to eq(1000)
      end

      context 'when namespace limit is set' do
        before do
          namespace.shared_runners_minutes_limit = 500
        end

        it 'returns namespace limit' do
          is_expected.to eq(500)
        end
      end
    end
  end

  describe '#shared_runner_minutes_supported?' do
    subject { namespace.shared_runner_minutes_supported? }

    context 'when is subgroup' do
      before do
        namespace.parent = build(:group)
      end

      context 'when shared_runner_minutes_on_root_namespace is disabled' do
        before do
          stub_feature_flags(shared_runner_minutes_on_root_namespace: false)
        end

        it 'returns true' do
          is_expected.to eq(true)
        end
      end

      context 'when shared_runner_minutes_on_root_namespace is enabled', :nested_groups do
        before do
          stub_feature_flags(shared_runner_minutes_on_root_namespace: true)
        end

        it 'returns false' do
          is_expected.to eq(false)
        end
      end
    end

    context 'when is root' do
      it 'returns true' do
        is_expected.to eq(true)
      end
    end
  end

  describe '#shared_runners_minutes_limit_enabled?' do
    subject { namespace.shared_runners_minutes_limit_enabled? }

    context 'with project' do
      let!(:project) do
        create(:project,
          namespace: namespace,
          shared_runners_enabled: true)
      end

      context 'when no limit defined' do
        it { is_expected.to be_falsey }
      end

      context 'when limit is defined' do
        before do
          namespace.shared_runners_minutes_limit = 500
        end

        it { is_expected.to be_truthy }

        context 'when is subgroup', :nested_groups do
          before do
            stub_feature_flags(shared_runner_minutes_on_root_namespace: true)
            namespace.parent = build(:group)
          end

          it { is_expected.to be_falsey }
        end
      end
    end

    context 'without project' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#shared_runners_enabled?' do
    subject { namespace.shared_runners_enabled? }

    context 'subgroup with shared runners enabled project' do
      let(:subgroup) { create(:group, parent: namespace) }
      let!(:subproject) { create(:project, namespace: subgroup, shared_runners_enabled: true) }

      context 'when shared_runner_minutes_on_root_namespace is disabled' do
        before do
          stub_feature_flags(shared_runner_minutes_on_root_namespace: false)
        end

        it "returns false" do
          is_expected.to eq(false)
        end
      end

      context 'when shared_runner_minutes_on_root_namespace is enabled', :nested_groups do
        before do
          stub_feature_flags(shared_runner_minutes_on_root_namespace: true)
        end

        it "returns true" do
          is_expected.to eq(true)
        end
      end
    end

    context 'group with shared runners enabled project' do
      let!(:project) { create(:project, namespace: namespace, shared_runners_enabled: true) }

      it "returns true" do
        is_expected.to eq(true)
      end
    end

    context 'group without projects' do
      it "returns false" do
        is_expected.to eq(false)
      end
    end
  end

  describe '#shared_runners_minutes_used?' do
    subject { namespace.shared_runners_minutes_used? }

    context 'with project' do
      let!(:project) do
        create(:project,
          namespace: namespace,
          shared_runners_enabled: true)
      end

      context 'when limit is defined' do
        context 'when limit is used' do
          let(:namespace) { create(:namespace, :with_used_build_minutes_limit) }

          it { is_expected.to be_truthy }
        end

        context 'when limit not yet used' do
          let(:namespace) { create(:namespace, :with_not_used_build_minutes_limit) }

          it { is_expected.to be_falsey }
        end

        context 'when minutes are not yet set' do
          it { is_expected.to be_falsey }
        end
      end

      context 'without limit' do
        let(:namespace) { create(:namespace, :with_build_minutes_limit) }

        it { is_expected.to be_falsey }
      end
    end

    context 'without project' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#actual_plan' do
    context 'when namespace has a plan associated' do
      before do
        namespace.update_attribute(:plan, gold_plan)
      end

      it 'generates a subscription with that plan code' do
        expect(namespace.actual_plan).to eq(gold_plan)
        expect(namespace.gitlab_subscription).to be_present
      end
    end

    context 'when namespace has a subscription associated' do
      before do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan)
      end

      it 'returns the plan from the subscription' do
        expect(namespace.actual_plan).to eq(gold_plan)
        expect(namespace.gitlab_subscription).to be_present
      end
    end

    context 'when namespace does not have a subscription associated' do
      it 'generates a subscription with the Free plan' do
        expect(namespace.actual_plan).to eq(free_plan)
        expect(namespace.gitlab_subscription).to be_present
      end
    end
  end

  describe '#actual_plan_name' do
    context 'when namespace has a subscription associated' do
      before do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan)
      end

      it 'returns an associated plan name' do
        expect(namespace.actual_plan_name).to eq 'gold'
      end
    end

    context 'when namespace does not have subscription associated' do
      it 'returns a free plan name' do
        expect(namespace.actual_plan_name).to eq 'free'
      end
    end
  end

  describe '#billable_members_count' do
    context 'with a user namespace' do
      let(:user) { create(:user) }

      it 'returns 1' do
        expect(user.namespace.billable_members_count).to eq(1)
      end
    end

    context 'with a group namespace' do
      let(:group) { create(:group) }
      let(:developer) { create(:user) }
      let(:guest) { create(:user) }

      before do
        group.add_developer(developer)
        group.add_guest(guest)
      end

      context 'with a gold plan' do
        it 'does not count guest users' do
          create(:gitlab_subscription, namespace: group, hosted_plan: gold_plan)

          expect(group.billable_members_count).to eq(1)
        end
      end

      context 'with other plans' do
        %i[bronze_plan silver_plan].each do |plan|
          it 'counts guest users' do
            create(:gitlab_subscription, namespace: group, hosted_plan: send(plan))

            expect(group.billable_members_count).to eq(2)
          end
        end
      end
    end
  end

  describe '#file_template_project_id' do
    it 'is cleared before validation' do
      project = create(:project, namespace: namespace)

      namespace.file_template_project_id = project.id

      expect(namespace).to be_valid
      expect(namespace.file_template_project_id).to be_nil
    end
  end

  describe '#checked_file_template_project' do
    it 'is always nil' do
      namespace.file_template_project_id = create(:project, namespace: namespace).id

      expect(namespace.checked_file_template_project).to be_nil
    end
  end

  describe '#checked_file_template_project_id' do
    it 'is always nil' do
      namespace.file_template_project_id = create(:project, namespace: namespace).id

      expect(namespace.checked_file_template_project_id).to be_nil
    end
  end

  describe '#store_security_reports_available?' do
    subject { namespace.store_security_reports_available? }

    context 'when store_security_reports feature is enabled' do
      before do
        stub_feature_flags(store_security_reports: true)
        stub_licensed_features(sast: true)
      end

      it 'returns true' do
        expect(subject).to be_truthy
      end
    end

    context 'when store_security_reports feature is disabled' do
      before do
        stub_feature_flags(store_security_reports: false)
        stub_licensed_features(sast: true)
      end

      it 'returns false' do
        expect(subject).to be_falsey
      end
    end

    context 'when no security report feature is available' do
      before do
        stub_feature_flags(store_security_reports: true)
      end

      it 'returns false' do
        expect(subject).to be_falsey
      end
    end
  end
end
