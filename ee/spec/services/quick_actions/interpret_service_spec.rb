# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QuickActions::InterpretService do
  let_it_be(:user) { create(:user) }
  let_it_be(:user2) { create(:user) }
  let_it_be(:user3) { create(:user) }
  let_it_be(:developer) { create(:user) }
  let_it_be_with_refind(:group) { create(:group) }
  let_it_be_with_refind(:project) { create(:project, :repository, :public, group: group) }

  let_it_be_with_reload(:merge_request) { create(:merge_request, source_project: project) }
  let_it_be_with_reload(:issue) { create(:issue, project: project) }
  let_it_be_with_reload(:epic) { create(:epic, group: group) }

  let(:current_user) { developer }
  let(:current_project) { project }

  let(:params) { nil }

  let(:service) { described_class.new(current_project, target, current_user, content, params) }

  before do
    stub_licensed_features(multiple_issue_assignees: true,
                           multiple_merge_request_assignees: true)

    current_project.add_developer(developer) if current_project
  end

  let(:include_action) { include(a_hash_including(name: action)) }

  shared_examples 'quick action is unavailable' do |action_name|
    let(:action) { action_name }

    it 'does not recognize command' do
      expect(updates).to be_empty
    end

    it 'does not list action' do
      expect(service.available_commands).not_to include_action
    end
  end

  shared_examples 'empty command' do
    it 'populates {} if content contains an unsupported command' do
      expect(updates).to be_empty
    end
  end

  shared_examples 'quick action is available' do |action_name|
    let(:action) { action_name }

    it 'recognizes command and applies updates' do
      expect(updates).to eq(command_updates)
    end

    it 'lists action' do
      expect(service.available_commands).to include_action
    end
  end

  shared_examples 'a failed command' do
    it 'performs no updates, and returns a warning' do
      expect(response).to have_attributes(
        updates: be_empty,
        messages: be_empty,
        warnings: eq(warning)
      )
    end
  end

  around do |example|
    travel_to Time.new(2010, 10, 10, 12, 12, 12, "+00:00")
    example.run
    travel_back
  end

  # rubocop:disable RSpec/EmptyExampleGroup
  def self.for_issues_and_merge_requests(&blk)
    context 'for an issue' do
      let(:target) { issue }

      instance_exec(&blk)
    end

    context 'for a merge request' do
      let(:target) { merge_request }

      instance_exec(&blk)
    end
  end
  # rubocop:enable RSpec/EmptyExampleGroup

  def target_for_type
    case target_type
    when :merge_request
      merge_request
    when :issue
      issue
    end
  end

  # these are used both in #execute but also in #explain
  let(:response) { service.execute }
  let(:updates) { response.updates }
  let(:message) { response.messages }
  let(:warnings) { response.warnings }

  describe '#execute' do
    describe 'assign command' do
      context 'when unassigning at the same time' do
        for_issues_and_merge_requests do
          context 'unassigning user-2 and assigning user-3' do
            let(:content) { "/unassign @#{user2.username}\n/assign @#{user3.username}" }

            it 'fetches assignees and populates them if content contains /assign' do
              target.update!(assignee_ids: [user.id, user2.id])

              expect(updates[:assignee_ids]).to contain_exactly(user.id, user3.id)
            end
          end

          context 'assign command with multiple assignees' do
            let(:content) { "/unassign @#{user.username}\n/assign @#{user2.username} @#{user3.username}" }

            it 'fetches assignee and populates assignee_ids if content contains /assign' do
              target.update!(assignee_ids: [user.id])

              expect(updates[:assignee_ids]).to contain_exactly(user2.id, user3.id)
            end
          end
        end
      end

      context 'Merge Request' do
        let(:target) { merge_request }
        let(:content) { "/assign @#{user2.username}" }

        it 'fetches assignees and populates them if content contains /assign' do
          target.update(assignee_ids: [user.id])

          expect(updates[:assignee_ids]).to match_array([user.id, user2.id])
        end

        context 'assign command with multiple assignees' do
          let(:content) { "/assign @#{user.username}\n/assign @#{user2.username} @#{user3.username}" }

          it 'fetches assignee and populates assignee_ids if content contains /assign' do
            merge_request.update(assignee_ids: [user.id])

            expect(updates[:assignee_ids]).to match_array([user.id, user2.id, user3.id])
          end

          context 'unlicensed' do
            before do
              stub_licensed_features(multiple_merge_request_assignees: false)
            end

            let(:content) { "/assign @#{user2.username} @#{user3.username}" }

            it 'only assigns the first assignee, and unassigns the current assignee' do
              merge_request.update(assignee_ids: [user.id])

              expect(updates[:assignee_ids]).to match_array([user2.id])
            end
          end
        end
      end
    end

    describe '/title on epic' do
      let(:new_title) { 'new title' }
      let(:content) { "/title #{new_title}" }
      let(:target) { epic }

      before do
        group.add_developer(developer)
      end

      context 'when epics are disabled' do
        it_behaves_like 'quick action is unavailable', :title
      end

      context 'when epics are enabled' do
        before do
          stub_licensed_features(epics: true)
        end

        it 'marks the title for update' do
          expect(updates).to eq(title: new_title)
        end

        it 'has an appropriate message' do
          expect(message).to eq(%Q(Changed the title to "#{new_title}".))
        end

        it 'is available' do
          expect(service.available_commands).to include(a_hash_including(name: :title, description: 'Change title'))
        end
      end
    end

    describe '/close' do
      let(:content) { '/close' }

      context 'an epic' do
        before do
          group.add_developer(developer)
        end

        let(:target) { epic }

        context 'when epics are disabled' do
          it_behaves_like 'quick action is unavailable', :close
        end

        context 'when the epic is closed' do
          before do
            stub_licensed_features(epics: true)
            epic.close
          end

          it_behaves_like 'quick action is unavailable', :epic
        end

        context 'when epics are available' do
          before do
            stub_licensed_features(epics: true)
          end

          it 'sets correct updates' do
            expect(updates).to eq(state_event: 'close')
          end

          it 'produces the correct message' do
            expect(message).to eq('Closed this epic.')
          end

          it 'is available' do
            expect(service.available_commands).to include(a_hash_including(name: :close, description: 'Close this epic'))
          end
        end
      end
    end

    describe '/unassign' do
      context 'Issue' do
        let(:target) { issue }

        context 'assigning user3 and unassigning user2' do
          let(:content) { "/assign @#{user3.username}\n/unassign @#{user2.username}" }

          it 'removes user2 and adds user3' do
            issue.update!(assignee_ids: [user.id, user2.id])

            expect(updates[:assignee_ids]).to match_array([user.id, user3.id])
          end
        end

        context 'assigning user3 and unassigning user3 and user2' do
          let(:content) { "/assign @#{user3.username}\n/unassign @#{user2.username} @#{user3.username}" }

          it 'sets assignees to just user' do
            issue.update!(assignee_ids: [user.id, user2.id])

            expect(updates[:assignee_ids]).to match_array([user.id])
          end
        end

        context 'assign followed by blanket unassign' do
          let(:content) { "/assign @#{user3.username}\n/unassign" }

          it 'unassigns all the users if content contains /unassign' do
            issue.update!(assignee_ids: [user.id, user2.id])

            expect(updates[:assignee_ids]).to be_empty
          end
        end
      end

      context 'Merge Request' do
        let(:target) { merge_request }

        context 'unassigning a specific user' do
          let(:content) { "/unassign @#{user2.username}" }

          it 'unassigns user if content contains /unassign @user' do
            merge_request.update(assignee_ids: [user.id, user2.id])

            expect(updates[:assignee_ids]).to match_array([user.id])
          end
        end

        context 'unassigning user and user2' do
          let(:content) { "/unassign @#{user.username} @#{user2.username}" }

          it 'unassigns both users' do
            merge_request.update(assignee_ids: [user.id, user2.id, user3.id])

            expect(updates[:assignee_ids]).to match_array([user3.id])
          end
        end

        context 'unlicensed' do
          before do
            stub_licensed_features(multiple_merge_request_assignees: false)
          end

          let(:content) { "/unassign @#{user.username}" }

          it 'treats "/unassign user" as "/unassign"' do
            merge_request.update(assignee_ids: [user.id, user2.id, user3.id])

            expect(updates[:assignee_ids]).to be_empty
          end
        end
      end
    end

    context 'reassign command' do
      let(:content) { "/reassign #{current_user.to_reference}" }
      let(:command_updates) { { assignee_ids: [current_user.id] } }

      before do
        target.update!(assignee_ids: [user.id])
      end

      where(:target_type, :feature_flag) do
        [
          [:merge_request, :multiple_merge_request_assignees],
          [:issue,         :multiple_issue_assignees]
        ]
      end

      with_them do
        let(:target) { target_for_type }

        context 'feature_flag is off' do
          before do
            stub_licensed_features(feature_flag => false)
          end

          it_behaves_like 'quick action is unavailable', :reassign
        end

        it_behaves_like 'quick action is available', :reassign
      end
    end

    context 'iteration command' do
      let_it_be(:iteration) { create(:iteration, group: group) }

      let(:content) { "/iteration #{iteration.to_reference(project)}" }

      context 'when iterations are enabled' do
        before do
          stub_licensed_features(iterations: true)
        end

        context 'when iteration exists' do
          context 'with permissions' do
            before do
              group.add_developer(current_user)
            end

            it 'assigns an iteration to an issue' do
              _, updates, message = service.execute(content, issue)

              expect(updates).to eq(iteration: iteration)
              expect(message).to eq("Set the iteration to #{iteration.to_reference}.")
            end
          end

          context 'when the user does not have enough permissions' do
            before do
              allow(current_user).to receive(:can?).with(:use_quick_actions).and_return(true)
              allow(current_user).to receive(:can?).with(:admin_issue, project).and_return(false)
            end

            it 'returns empty message' do
              _, updates, message = service.execute(content, issue)

              expect(updates).to be_empty
              expect(message).to be_empty
            end
          end
        end

        context 'when iteration does not exist' do
          let(:content) { "/iteration none" }

          it 'returns empty message' do
            _, updates, message = service.execute(content, issue)

            expect(updates).to be_empty
            expect(message).to be_empty
          end
        end
      end

      context 'when iterations are disabled' do
        before do
          stub_licensed_features(iterations: false)
        end

        it 'does not recognize /iteration' do
          _, updates = service.execute(content, issue)

          expect(updates).to be_empty
        end
      end
    end

    context 'remove_iteration command' do
      let_it_be(:iteration) { create(:iteration, group: group) }

      let(:content) { '/remove_iteration' }

      context 'when iterations are enabled' do
        before do
          stub_licensed_features(iterations: true)
          issue.update!(iteration: iteration)
        end

        it 'removes an assigned iteration from an issue' do
          _, updates, message = service.execute(content, issue)

          expect(updates).to eq(iteration: nil)
          expect(message).to eq("Removed #{iteration.to_reference} iteration.")
        end

        context 'when the user does not have enough permissions' do
          before do
            allow(current_user).to receive(:can?).with(:use_quick_actions).and_return(true)
            allow(current_user).to receive(:can?).with(:admin_issue, project).and_return(false)
          end

          it 'returns empty message' do
            _, updates, message = service.execute(content, issue)

            expect(updates).to be_empty
            expect(message).to be_empty
          end
        end
      end

      context 'when iterations are disabled' do
        before do
          stub_licensed_features(iterations: false)
        end

        it 'does not recognize /remove_iteration' do
          _, updates = service.execute(content, issue)

          expect(updates).to be_empty
        end
      end
    end

    describe '/epic' do
      let(:target) { issue }
      let(:content) { "/epic #{epic.to_reference(project)}" }

      context 'when epics are enabled' do
        before do
          stub_licensed_features(epics: true)
        end

        context 'when epic exists' do
          it 'assigns an issue to an epic' do
            expect(updates).to eq(epic: epic)
            expect(message).to eq('Added an issue to an epic.')
          end

          context 'when an issue belongs to a project without group' do
            let(:user_project)    { create(:project) }
            let(:current_project) { user_project }
            let(:target)          { create(:issue, project: user_project) }

            before do
              user_project.add_developer(current_user)
            end

            it 'does not assign an issue to an epic' do
              expect(updates).to be_empty
            end
          end

          context 'when issue is already added to epic' do
            let(:target) { create(:issue, project: project, epic: epic) }
            let(:warning) { "Issue #{target.to_reference} has already been added to epic #{epic.to_reference}." }

            it_behaves_like 'a failed command'
          end
        end

        context 'user cannot read epic' do
          let(:warning) { %q(This epic does not exist or you don't have sufficient permission.) }

          context 'because epic does not exist' do
            let(:content) { "/epic none" }

            it_behaves_like 'a failed command'
          end

          context 'because user has insufficient permissions' do
            before do
              allow(current_user).to receive(:can?).with(:use_quick_actions).and_return(true)
              allow(current_user).to receive(:can?).with(:admin_issue, issue).and_return(true)
              allow(current_user).to receive(:can?).with(:read_epic, epic).and_return(false)
            end

            it_behaves_like 'a failed command'
          end
        end
      end

      context 'when epics are disabled' do
        it_behaves_like 'quick action is unavailable', :epic
      end
    end

    context 'child_epic command' do
      let_it_be(:subgroup) { create(:group, parent: group) }

      let(:another_group) { create(:group) }
      let(:child_epic) { create(:epic, group: group) }
      let(:content) { "/child_epic #{child_epic&.to_reference(epic)}" }

      let(:target) { epic }

      shared_examples 'epic relation is not added' do
        it 'does not add child epic to epic' do
          service.execute
          child_epic.reload

          expect(child_epic.parent).to be_nil
        end
      end

      shared_examples 'epic relation is added' do
        # This command does not use the #apply_updates method
        let(:command_updates) { {} }

        it_behaves_like 'quick action is available', :child_epic

        it 'adds child epic relation to the epic' do
          service.execute
          child_epic.reload

          expect(child_epic.parent).to eq(epic)
        end
      end

      context 'when subepics are enabled' do
        before do
          stub_licensed_features(epics: true, subepics: true)
        end

        context 'when a user does not have permissions to add epic relations' do
          it_behaves_like 'epic relation is not added'
          it_behaves_like 'quick action is unavailable', :child_epic
        end

        context 'when a user has permissions to add epic relations' do
          before do
            group.add_developer(current_user)
            another_group.add_developer(current_user)
          end

          it_behaves_like 'epic relation is added'

          for_issues_and_merge_requests { it_behaves_like 'quick action is unavailable', :child_epic }

          context 'when passed child epic is nil' do
            let(:child_epic) { nil }

            it 'does not add child epic to epic' do
              expect { service.execute }.not_to change { epic.children.count }
            end

            it 'does not raise error' do
              expect { service.execute }.not_to raise_error
            end
          end

          context 'when child_epic is already linked to an epic' do
            let(:another_epic) { create(:epic, group: group) }

            before do
              child_epic.update!(parent: another_epic)
            end

            it_behaves_like 'epic relation is added'
          end

          context 'when child epic is in a subgroup of parent epic' do
            let(:child_epic) { create(:epic, group: subgroup) }

            it_behaves_like 'epic relation is added'
          end

          context 'when child epic is in a parent group of the parent epic' do
            let(:child_epic) { create(:epic, group: group) }

            before do
              epic.update!(group: subgroup)
            end

            it_behaves_like 'epic relation is not added'
          end

          context 'when child epic is in a different group than parent epic' do
            let(:child_epic) { create(:epic, group: another_group) }
            let(:command_updates) { {} }
            let(:warning) do
              ["This epic can't be added",
               "because it must belong to the same group as the parent,",
               "or subgroup of the parent epic’s group"].join(' ')
            end

            it_behaves_like 'epic relation is not added'
            it_behaves_like 'quick action is available', :child_epic
            it_behaves_like 'a failed command'
          end
        end
      end

      context 'when epics are disabled' do
        let(:target) { epic }

        before do
          group.add_developer(current_user)
        end

        it_behaves_like 'epic relation is not added'
        it_behaves_like 'quick action is unavailable', :child_epic
      end
    end

    describe '/remove_child_epic &child_epic' do
      let_it_be(:child_epic, reload: true) { create(:epic, group: group, parent: epic) }
      let_it_be(:subgroup) { create(:group, parent: group) }
      let_it_be(:another_group) { create(:group) }

      let(:content) { "/remove_child_epic #{child_epic.to_reference(epic)}" }
      let(:command_updates) { {} }

      let(:target) { epic }

      shared_examples 'failure to remove epic relation' do
        it 'does not remove child_epic from epic' do
          expect(child_epic.parent).to eq(epic)

          service.execute
          child_epic.reload

          expect(child_epic.parent).to eq(epic)
        end

        it 'tells us why it failed if available' do
          if service.available_commands.pluck(:name).include?(:remove_child_epic)
            expect(warnings).not_to be_empty
          end
        end
      end

      shared_examples 'removal of epic relation' do
        it 'removes child_epic from epic' do
          expect(child_epic.parent).to eq(epic)

          service.execute
          child_epic.reload

          expect(child_epic.parent).to be_nil
        end
      end

      context 'when subepics are enabled' do
        before do
          stub_licensed_features(epics: true, subepics: true)
          epic.reload
        end

        context 'when a user does not have permissions to remove epic relations' do
          it_behaves_like 'failure to remove epic relation'
          it_behaves_like 'quick action is unavailable', :remove_child_epic
        end

        context 'when a user has permissions to remove epic relations' do
          before do
            group.add_developer(current_user)
            another_group.add_developer(current_user)
          end

          it_behaves_like 'quick action is available', :remove_child_epic

          for_issues_and_merge_requests do
            it_behaves_like 'quick action is unavailable', :remove_child_epic
          end

          it_behaves_like 'removal of epic relation'

          context 'when trying to remove child epic from a different epic' do
            let(:target) { create(:epic, group: group) }

            it_behaves_like 'failure to remove epic relation'
          end

          context 'when child epic is in a subgroup of parent epic' do
            let(:child_epic) { create(:epic, group: subgroup, parent: epic) }

            it_behaves_like 'removal of epic relation'
            it_behaves_like 'quick action is available', :remove_child_epic
          end

          context 'when child and parent epics are in different groups' do
            context 'when child epic is in a parent group of the parent epic' do
              before do
                epic.update!(group: subgroup)
              end

              it_behaves_like 'removal of epic relation'
              it_behaves_like 'quick action is available', :remove_child_epic
            end

            context 'when child epic is in a different group than parent epic' do
              before do
                epic.update!(group: another_group)
              end

              it_behaves_like 'removal of epic relation'
              it_behaves_like 'quick action is available', :remove_child_epic
            end
          end
        end
      end

      context 'when subepics are disabled' do
        before do
          stub_licensed_features(epics: true, subepics: false)
          group.add_developer(current_user)
        end

        it_behaves_like 'failure to remove epic relation'
        it_behaves_like 'quick action is unavailable', :remove_child_epic
      end
    end

    describe '/label on epics' do
      let_it_be(:bug) { create(:group_label, title: 'bug', group: group) }
      let_it_be(:project_label) { create(:label, title: 'project_label') }
      let(:label) { bug }

      let(:current_project) { nil }
      let(:target) { epic }
      let(:content) { "/label ~#{label.title} ~#{project_label.title}" }

      context 'when epics are enabled' do
        before do
          stub_licensed_features(epics: true)
        end

        context 'when a user has permissions to label an epic' do
          before do
            group.add_developer(current_user)
          end

          it 'populates valid label ids', :aggregate_failures do
            expect(updates).to eq(add_label_ids: [label.id])
            expect(message).to eq(%Q(Added ~"#{label.title}" label.))
          end
        end

        context 'when a user does not have permissions to label an epic' do
          it 'does not populate any labels' do
            expect(updates).to be_empty
          end
        end
      end

      context 'when epics are disabled' do
        it 'does not populate any labels' do
          group.add_developer(current_user)

          expect(updates).to be_empty
        end
      end
    end

    describe '/remove_epic' do
      let(:content) { "/remove_epic #{epic.to_reference(project)}" }
      let(:target) { issue }

      before do
        issue.update!(epic: epic)
      end

      context 'when epics are disabled' do
        it 'is not recognized' do
          expect(updates).to be_empty
        end
      end

      context 'when subepics are enabled' do
        before do
          stub_licensed_features(epics: true, subepics: true)
        end

        it 'unassigns an issue from an epic' do
          expect(updates).to eq(epic: nil)
        end
      end
    end

    describe '/approve' do
      let(:content) { '/approve' }
      let(:target) { merge_request }

      it 'approves the current merge request' do
        service.execute

        expect(merge_request.approved_by_users).to eq([current_user])
      end

      it 'tells us that the current user approved the merge request' do
        expect(message).to eq('Approved the current merge request.')
      end

      context "when the user can't approve" do
        before do
          project.team.truncate
          project.add_guest(current_user)
        end

        it 'does not approve the MR' do
          service.execute

          expect(merge_request.approved_by_users).to be_empty
        end

        it_behaves_like 'quick action is unavailable', :approve
      end
    end

    describe '/submit_review' do
      where(:note) do
        [
          'I like it',
          '/submit_review'
        ]
      end

      with_them do
        let(:target) { merge_request }
        let(:content) { '/submit_review' }
        let!(:draft_note) { create(:draft_note, note: note, merge_request: merge_request, author: current_user) }

        before do
          stub_licensed_features(batch_comments: true)
        end

        it 'submits the users current review', :aggregate_failures do
          messages = service.execute.messages

          expect { draft_note.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(messages).to eq('Submitted the current review.')
        end
      end
    end

    shared_examples 'weight command' do
      it 'populates weight specified by the /weight command' do
        expect(updates).to eq(weight: weight)
      end
    end

    shared_examples 'clear weight command' do
      it 'populates weight: nil if content contains /clear_weight' do
        target.update!(weight: 5)

        expect(updates).to eq(weight: nil)
      end
    end

    context 'issuable weights licensed' do
      let(:target) { issue }

      before do
        stub_licensed_features(issue_weights: true)
      end

      describe '/weight' do
        let(:content) { "/weight #{weight}" }

        it_behaves_like 'weight command' do
          let(:weight) { 5 }
        end

        it_behaves_like 'weight command' do
          let(:weight) { 0 }
        end

        context 'when weight is negative' do
          let(:content) { "/weight -10" }

          it 'does not populate weight' do
            expect(updates).to be_empty
          end
        end
      end

      describe '/clear_weight' do
        it_behaves_like 'clear weight command' do
          let(:content) { '/clear_weight' }
        end
      end
    end

    context 'issuable weights unlicensed' do
      before do
        stub_licensed_features(issue_weights: false)
      end
      let(:target) { issue }

      it_behaves_like 'quick action is unavailable', :weight do
        let(:content) { '/weight 5' }
      end

      it_behaves_like 'quick action is unavailable', :clear_weight do
        let(:content) { '/clear_weight' }
      end
    end

    describe '/merge' do
      let(:content) { '/merge' }

      context 'not persisted merge request can not be merged' do
        it_behaves_like 'empty command' do
          let(:target) { build(:merge_request, source_project: project) }
        end
      end

      shared_examples 'when target project requires approval' do
        let(:target) { merge_request }
        let(:last_diff_sha) { merge_request.diff_head_sha }
        let(:params) { { merge_request_diff_head_sha: last_diff_sha } }

        before do
          merge_request.target_project.update!(approvals_before_merge: 1)
          merge_request.clear_memoization(:approval_state)
        end

        context 'merge request is not approved' do
          it_behaves_like 'empty command'
        end

        context 'merge request is approved' do
          before do
            merge_request.approvals.create(user: current_user)
          end

          it 'marks the target for merge' do
            expect(updates).to eq(merge: last_diff_sha)
          end
        end
      end

      context 'merge_orchestration_service is active' do
        it_behaves_like 'when target project requires approval'
      end

      context 'merge_orchestration_service is not active' do
        before do
          stub_feature_flags(merge_orchestration_service: false)
        end

        it_behaves_like 'when target project requires approval'
      end
    end

    describe '/relate' do
      let(:target) { issue }

      shared_examples 'relate command' do
        it 'relates issues', :aggregate_failures do
          expect(service.execute.updates).to be_empty
          expect(IssueLink.where(source: issue).map(&:target)).to match_array(issues_related)
        end
      end

      shared_examples 'relation examples' do
        context 'relate a single issue' do
          let(:other_issue) { second_issue }
          let(:issues_related) { [other_issue] }
          let(:content) { "/relate #{other_issue.to_reference}" }

          it_behaves_like 'relate command'
        end

        context 'relate multiple issues at once' do
          let(:issues_related) { [second_issue, third_issue] }
          let(:content) { "/relate #{second_issue.to_reference} #{third_issue.to_reference}" }

          it_behaves_like 'relate command'
        end

        context 'empty relate command' do
          let(:issues_related) { [] }
          let(:content) { '/relate' }

          it_behaves_like 'relate command'
        end

        context 'already having related issues' do
          let(:issues_related) { [second_issue, third_issue] }
          let(:content) { "/relate #{third_issue.to_reference(project)}" }

          before do
            create(:issue_link, source: issue, target: second_issue)
          end

          it_behaves_like 'relate command'
        end
      end

      context 'user is member of group' do
        let_it_be(:group_member) { create(:user) }

        let(:current_user) { group_member }

        before do
          group.add_developer(group_member)
        end

        include_examples 'relation examples' do
          let_it_be(:second_issue) { create(:issue, project: project) }
          let_it_be(:third_issue) { create(:issue, project: project) }
        end

        context 'cross project' do
          let_it_be(:another_group) { create(:group, :public) }
          let_it_be(:other_project) { create(:project, group: another_group) }

          before do
            another_group.add_developer(current_user)
          end

          include_examples 'relation examples' do
            let_it_be(:second_issue) { create(:issue, project: project) }
            let_it_be(:third_issue) { create(:issue, project: project) }
          end

          context 'relate a non-existing issue' do
            let(:issues_related) { [] }
            let(:content) { "/relate imaginary##{non_existing_record_iid}" }

            it_behaves_like 'relate command'
          end

          context 'relate a private issue' do
            let(:private_project) { create(:project, :private) }
            let(:other_issue) { create(:issue, project: private_project) }
            let(:issues_related) { [] }
            let(:content) { "/relate #{other_issue.to_reference(project)}" }

            it_behaves_like 'relate command'
          end
        end
      end
    end
  end

  describe '#explain' do
    let(:explanations) { service.explain.messages }

    describe 'unassign command' do
      let(:content) { '/unassign' }
      let(:target) { create(:issue, project: project, assignees: [user, user2]) }

      it "includes all assignees' references" do
        expect(explanations).to eq(["Removes assignees @#{user.username} and @#{user2.username}."])
      end
    end

    describe 'unassign command with assignee references' do
      let(:content) { "/unassign @#{user.username} @#{user3.username}" }
      let(:target) { create(:issue, project: project, assignees: [user, user2, user3]) }

      it 'includes only selected assignee references' do
        expect(explanations).to eq(["Removes assignees @#{user.username} and @#{user3.username}."])
      end
    end

    describe 'weight command' do
      let(:target) { issue }
      let(:content) { '/weight 4' }

      it 'includes the number' do
        expect(explanations).to eq(['Sets weight to 4.'])
      end
    end

    context 'epic commands' do
      let_it_be(:epic, reload: true) { create(:epic, group: group) }
      let_it_be(:epic2, reload: true) { create(:epic, group: group) }
      let(:target) { epic }

      before do
        stub_licensed_features(epics: true, subepics: true)
        group.add_developer(current_user)
      end

      shared_examples 'adds epic relation' do |relation|
        context 'when correct epic reference' do
          let(:content) { "/#{relation}_epic #{epic2&.to_reference(epic)}" }
          let(:explain_action) { relation == :child ? 'Adds' : 'Sets'}
          let(:execute_action) { relation == :child ? 'Added' : 'Set'}
          let(:article)        { relation == :child ? 'a' : 'the'}

          it 'returns explain message with epic reference' do
            expect(explanations)
              .to eq(["#{explain_action} #{epic2.group.name}&#{epic2.iid} as #{relation} epic."])
          end

          it 'returns successful execution message' do
            expect(message)
              .to eq("#{execute_action} #{epic2.group.name}&#{epic2.iid} as #{article} #{relation} epic.")
          end
        end

        context 'when epic reference is wrong' do |relation|
          let(:content) { "/#{relation}_epic qwe" }

          it 'returns empty explain message' do
            expect(explanations).to eq([])
          end
        end
      end

      shared_examples 'target epic does not exist' do |relation|
        it_behaves_like 'a failed command' do
          let(:warning) { "#{relation.capitalize} epic doesn't exist." }
        end
      end

      shared_examples 'epics are already related' do
        it_behaves_like 'a failed command' do
          let(:warning) { "Given epic is already related to this epic." }
        end
      end

      shared_examples 'without permissions for action' do
        it_behaves_like 'a failed command' do
          let(:warning) { "You don't have sufficient permission to perform this action." }
        end
      end

      context 'child_epic command' do
        let(:content) { "/child_epic #{epic2&.to_reference(epic)}" }

        it_behaves_like 'adds epic relation', :child

        context 'when epic is already a child epic' do
          before do
            epic2.update!(parent: epic)
          end

          it_behaves_like 'epics are already related'
        end

        context 'when epic is the parent epic' do
          before do
            epic.update!(parent: epic2)
          end

          it_behaves_like 'epics are already related'
        end

        context 'when epic does not exist' do
          let(:content) { "/child_epic none" }

          it_behaves_like 'target epic does not exist', :child
        end

        context 'when user has no permission to read epic' do
          before do
            allow(current_user).to receive(:can?).with(:use_quick_actions).and_return(true)
            allow(current_user).to receive(:can?).with(:admin_epic, epic).and_return(true)
            allow(current_user).to receive(:can?).with(:read_epic, epic2).and_return(false)
          end

          it_behaves_like 'without permissions for action'
        end
      end

      context 'remove_child_epic command' do
        context 'when correct epic reference' do
          let(:content) { "/remove_child_epic #{epic2&.to_reference(epic)}" }

          before do
            epic2.update!(parent: epic)
          end

          it 'returns explain message with epic reference' do
            expect(explanations).to eq(["Removes #{epic2.group.name}&#{epic2.iid} from child epics."])
          end

          it 'returns successful execution message' do
            expect(message)
              .to eq("Removed #{epic2.group.name}&#{epic2.iid} from child epics.")
          end
        end

        context 'when epic reference is wrong' do
          let(:content) { "/remove_child_epic qwe" }

          it 'returns empty explain message' do
            expect(explanations).to eq([])
          end
        end

        context 'when epic refered to is not a child of this epic' do
          let(:content) { "/remove_child_epic #{epic2&.to_reference(epic)}" }

          before do
            epic.update!(parent: nil)
          end

          it_behaves_like 'a failed command' do
            let(:warning) { "Child epic does not exist." }
          end
        end
      end

      context 'parent_epic command' do
        it_behaves_like 'adds epic relation', :parent

        context 'when epic is already a parent epic' do
          let(:content) { "/parent_epic #{epic2&.to_reference(epic)}" }

          before do
            epic.update!(parent: epic2)
          end

          it_behaves_like 'epics are already related'
        end

        context 'when epic is a an existing child epic' do
          let(:content) { "/parent_epic #{epic2&.to_reference(epic)}" }

          before do
            epic2.update!(parent: epic)
          end

          it_behaves_like 'epics are already related'
        end

        context 'when epic does not exist' do
          let(:content) { "/parent_epic none" }

          it_behaves_like 'target epic does not exist', :parent
        end

        context 'when user has no permission to read epic' do
          let(:content) { "/parent_epic #{epic2&.to_reference(epic)}" }

          before do
            allow(current_user).to receive(:can?).with(:use_quick_actions).and_return(true)
            allow(current_user).to receive(:can?).with(:admin_epic, epic).and_return(true)
            allow(current_user).to receive(:can?).with(:read_epic, epic2).and_return(false)
          end

          it_behaves_like 'without permissions for action'
        end
      end

      context 'remove_parent_epic command' do
        let(:content) { "/remove_parent_epic" }

        context 'when parent is present' do
          before do
            epic.parent = epic2
          end

          it 'returns explain message with epic reference' do
            expect(explanations).to eq(["Removes parent epic #{epic2.group.name}&#{epic2.iid}."])
          end

          it 'returns successful execution message' do
            expect(message)
              .to eq("Removed parent epic #{epic2.group.name}&#{epic2.iid}.")
          end
        end

        context 'when parent is not present' do
          before do
            epic.parent = nil
          end

          it 'returns empty explain message' do
            expect(explanations).to eq([])
          end

          it_behaves_like 'a failed command' do
            let(:warning) { "Parent epic is not present." }
          end
        end
      end
    end
  end
end
