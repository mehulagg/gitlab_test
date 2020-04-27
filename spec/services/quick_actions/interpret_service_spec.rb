# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QuickActions::InterpretService do
  let_it_be(:project) { create(:project, :public, :repository) }
  let_it_be(:private_project) { create(:project, :private) }
  let_it_be(:developer) { create(:user) }
  let_it_be(:developer2) { create(:user) }
  let_it_be(:guest) { create(:user) }
  let_it_be(:issue, reload: true) { create(:issue, project: project) }
  let_it_be(:basic_mr, reload: true) { create(:merge_request, source_project: project) }
  let_it_be(:milestone_9_10) { create(:milestone, project: project, title: '9.10') }
  let_it_be(:inprogress) { create(:label, project: project, title: 'In Progress') }
  let_it_be(:helmchart) { create(:label, project: project, title: 'Helm Chart Registry') }
  let_it_be(:bug) { create(:label, project: project, title: 'Bug') }

  let(:target) { issuable }
  let(:milestone) { milestone_9_10 }
  let(:commit) { create(:commit, project: project) }
  let(:note) { build(:note, commit_id: merge_request.diff_head_sha) }
  let(:current_user) { developer }
  let(:current_project) { project }
  let(:params) { nil }
  let(:content) { nil }
  let(:service) { described_class.new(current_project, target, current_user, content, params) }

  shared_context 'board context' do
    let_it_be(:board) { create(:board, project: project) }
    let_it_be(:todo) { create(:label, project: project, title: 'To Do') }
    let_it_be(:inreview) { create(:label, project: project, title: 'In Review') }
    let_it_be(:todo_list) { create(:list, board: board, label: todo) }
    let_it_be(:inreview_list) { create(:list, board: board, label: inreview) }
    let_it_be(:inprogress_list) { create(:list, board: board, label: inprogress) }
  end

  before do
    stub_licensed_features(multiple_issue_assignees: false,
                           multiple_merge_request_assignees: false)
    current_project.add_developer(developer)
    current_project.add_developer(developer2)
    current_project.add_guest(guest)
  end

  around do |example|
    travel_to Time.new(2010, 10, 10, 12, 12, 12, "+00:00")
    example.run
    travel_back
  end

  # rubocop:disable RSpec/EmptyExampleGroup
  def self.for_issues_and_merge_requests(&blk)
    context 'for an issue' do
      let(:issuable) { issue }

      instance_exec(&blk)
    end

    context 'for a merge request' do
      let(:issuable) { merge_request }

      instance_exec(&blk)
    end
  end
  # rubocop:enable RSpec/EmptyExampleGroup

  describe '#execute' do
    let(:merge_request) { basic_mr }

    let(:response) { service.execute }
    let(:updates) { response.updates }
    let(:messages) { response.messages }
    let(:message) { response.messages } # sugar

    let(:shrug) { Gitlab::QuickActions::IssuableActions::SHRUG }
    let(:table_flip) { Gitlab::QuickActions::IssuableActions::TABLEFLIP }

    shared_examples 'reopen command' do
      before do
        issuable.close!
      end

      it 'returns state_event: "reopen" if content contains /reopen' do
        expect(updates).to eq(state_event: 'reopen')
      end

      it 'returns the reopen message' do
        expect(messages).to eq("Reopened this #{issuable.to_ability_name.humanize(capitalize: false)}.")
      end
    end

    shared_examples 'close command' do
      it 'returns state_event: "close" if content contains /close' do
        expect(response.updates).to eq(state_event: 'close')
      end

      it 'returns the close message' do
        expect(messages).to eq("Closed this #{issuable.to_ability_name.humanize(capitalize: false)}.")
      end
    end

    shared_examples 'title command' do
      it 'populates title: "A brand new title" if content contains /title A brand new title' do
        expect(updates).to eq(title: 'A brand new title')
      end

      it 'returns the title message' do
        expect(messages).to eq(%{Changed the title to "A brand new title".})
      end
    end

    shared_examples 'milestone command' do
      before do
        milestone # populate the milestone
      end

      it 'fetches milestone and populates milestone_id if content contains /milestone' do
        expect(updates).to eq(milestone_id: milestone.id)
      end

      it 'returns the milestone message' do
        expect(messages).to eq("Set the milestone to #{milestone.to_reference}.")
      end

      context 'the milestone is wrong' do
        let(:content) { '/milestone %wrong-milestone' }

        it 'returns empty milestone message' do
          expect(messages).to be_empty
        end

        it 'returns a warning' do
          expect(response.warnings).to eq('Could not find milestone')
        end
      end
    end

    shared_examples 'remove_milestone command' do
      it 'populates milestone_id: nil if content contains /remove_milestone' do
        issuable.update!(milestone_id: milestone.id)

        expect(updates).to eq(milestone_id: nil)
      end

      it 'returns removed milestone message' do
        issuable.update!(milestone_id: milestone.id)

        expect(messages).to eq("Removed #{milestone.to_reference} milestone.")
      end
    end

    shared_examples 'label command' do
      before do
        bug # populate the label
        inprogress # populate the label
      end

      it 'fetches label ids and populates add_label_ids if content contains /label' do
        expect(updates).to eq(add_label_ids: [bug.id, inprogress.id])
      end

      it 'returns the label message' do
        expect(messages).to eq("Added #{bug.to_reference(format: :name)} #{inprogress.to_reference(format: :name)} labels.")
      end
    end

    shared_examples 'multiple label command' do
      before do
        bug # populate the label
        inprogress # populate the label
      end

      it 'fetches label ids and populates add_label_ids if content contains multiple /label' do
        expect(updates).to eq(add_label_ids: [inprogress.id, bug.id])
      end
    end

    shared_examples 'multiple label with same argument' do
      it 'prevents duplicate label ids and populates add_label_ids if content contains multiple /label' do
        inprogress # populate the label

        expect(updates).to eq(add_label_ids: [inprogress.id])
      end
    end

    shared_examples 'multiword label name starting without ~' do
      it 'fetches label ids and populates add_label_ids if content contains /label' do
        helmchart # populate the label

        expect(updates).to eq(add_label_ids: [helmchart.id])
      end
    end

    shared_examples 'label name is included in the middle of another label name' do
      it 'ignores the sublabel when the content contains the includer label name' do
        create(:label, project: project, title: 'Chart')

        expect(updates).to eq(add_label_ids: [helmchart.id])
      end
    end

    shared_examples 'unlabel command' do
      before do
        issuable.update!(label_ids: [inprogress.id]) # populate the label
      end

      it 'fetches label ids and populates remove_label_ids if content contains /unlabel' do
        expect(updates).to eq(remove_label_ids: [inprogress.id])
      end

      it 'returns the unlabel message' do
        expect(message).to eq("Removed #{inprogress.to_reference(format: :name)} label.")
      end
    end

    shared_examples 'multiple unlabel command' do
      before do
        issuable.update!(label_ids: [inprogress.id, bug.id]) # populate the label
      end

      it 'fetches label ids and populates remove_label_ids if content contains  mutiple /unlabel' do
        expect(updates).to eq(remove_label_ids: [inprogress.id, bug.id])
      end

      it 'returns the unlabel message' do
        expected = [inprogress, bug]
          .map { |lab| "Removed #{lab.to_reference(format: :name)} label." }
          .join(' ')

        expect(message).to eq(expected)
      end
    end

    shared_examples 'unlabel command with no argument' do
      it 'populates label_ids: [] if content contains /unlabel with no arguments' do
        issuable.update!(label_ids: [inprogress.id]) # populate the label

        expect(updates).to eq(label_ids: [])
      end
    end

    shared_examples 'relabel command' do
      before do
        issuable.update!(label_ids: [bug.id]) # populate the label
        inprogress # populate the label
      end

      it 'populates label_ids: [] if content contains /relabel' do
        expect(updates).to eq(label_ids: [inprogress.id])
      end

      it 'returns the relabel message' do
        expect(message).to eq("Replaced all labels with #{inprogress.to_reference(format: :name)} label.")
      end
    end

    shared_examples 'todo command' do
      it 'populates todo_event: "add" if content contains /todo' do
        expect(updates).to eq(todo_event: 'add')
      end

      it 'returns the todo message' do
        expect(message).to eq('Added a To Do.')
      end
    end

    shared_examples 'done command' do
      before do
        TodoService.new.mark_todo(issuable, developer)
      end

      it 'populates todo_event: "done" if content contains /done' do
        expect(updates).to eq(todo_event: 'done')
      end

      it 'returns the done message' do
        expect(message).to eq('Marked To Do as done.')
      end
    end

    shared_examples 'subscribe command' do
      it 'populates subscription_event: "subscribe" if content contains /subscribe' do
        expect(updates).to eq(subscription_event: 'subscribe')
      end

      it 'returns the subscribe message' do
        expect(message).to eq("Subscribed to this #{issuable.to_ability_name.humanize(capitalize: false)}.")
      end
    end

    shared_examples 'unsubscribe command' do
      before do
        issuable.subscribe(developer, project)
      end

      it 'populates subscription_event: "unsubscribe" if content contains /unsubscribe' do
        expect(updates).to eq(subscription_event: 'unsubscribe')
      end

      it 'returns the unsubscribe message' do
        expect(message).to eq("Unsubscribed from this #{issuable.to_ability_name.humanize(capitalize: false)}.")
      end
    end

    shared_examples 'due command' do
      let(:expected_date) { Date.new(2016, 8, 28) }

      it 'populates due_date: Date.new(2016, 8, 28) if content contains /due 2016-08-28' do
        expect(updates).to eq(due_date: expected_date)
      end

      it 'returns due_date message: Date.new(2016, 8, 28) if content contains /due 2016-08-28' do
        expect(message).to eq("Set the due date to #{expected_date.to_s(:medium)}.")
      end
    end

    shared_examples 'remove_due_date command' do
      before do
        issuable.update!(due_date: Date.today)
      end

      it 'populates due_date: nil if content contains /remove_due_date' do
        expect(updates).to eq(due_date: nil)
      end

      it 'returns Removed the due date' do
        expect(message).to eq('Removed the due date.')
      end
    end

    shared_examples 'wip command' do
      it 'returns wip_event: "wip" if content contains /wip' do
        expect(updates).to eq(wip_event: 'wip')
      end

      it 'returns the wip message' do
        expect(message).to eq("Marked this #{issuable.to_ability_name.humanize(capitalize: false)} as Work In Progress.")
      end
    end

    shared_examples 'unwip command' do
      before do
        issuable.update!(title: issuable.wip_title)
      end

      it 'returns wip_event: "unwip" if content contains /wip' do
        expect(updates).to eq(wip_event: 'unwip')
      end

      it 'returns the unwip message' do
        expect(messages).to eq("Unmarked this #{issuable.to_ability_name.humanize(capitalize: false)} as Work In Progress.")
      end
    end

    shared_examples 'estimate command' do
      it 'populates time_estimate: 3600 if content contains /estimate 1h' do
        expect(updates).to eq(time_estimate: 3600)
      end

      context 'the content contains /estimate 79d' do
        let(:content) { '/estimate 79d' }

        it 'returns the time_estimate formatted message' do
          expect(messages).to eq('Set time estimate to 3mo 3w 4d.')
        end
      end
    end

    shared_examples 'spend command' do
      it 'populates spend_time: 3600 if content contains /spend 1h' do
        expect(updates).to eq(spend_time: {
                                duration: 3600,
                                user_id: developer.id,
                                spent_at: DateTime.current.to_date
                              })
      end

      context 'the content is /spend -120m' do
        let(:content) { '/spend -120m' }

        it 'returns the spend_time message including the formatted duration and verb' do
          expect(message).to eq('Subtracted 2h spent time.')
        end
      end
    end

    shared_examples 'spend command with negative time' do
      it 'populates spend_time: -1800 if content contains /spend -30m' do
        expect(updates).to eq(spend_time: {
                                duration: -1800,
                                user_id: developer.id,
                                spent_at: DateTime.current.to_date
                              })
      end
    end

    shared_examples 'spend command with valid past date' do
      it 'populates spend time: 1800 with date in date type format' do
        expect(updates).to eq(spend_time: {
                                duration: 1800,
                                user_id: developer.id,
                                spent_at: date
                              })
      end
    end

    shared_examples 'spend command with invalid date' do
      let(:content) { '/spend 30m 17-99-99' }

      it 'will not create any note and timelog' do
        expect(updates).to be_empty
      end
    end

    shared_examples 'spend command with future date' do
      let(:date) { 1.year.from_now.to_date }
      let(:content) { "/spend 30m #{date.to_s(:ymd)}" }

      it 'will not create any note and timelog' do
        expect(updates).to be_empty
      end
    end

    shared_examples 'remove_estimate command' do
      it 'populates time_estimate: 0 if content contains /remove_estimate' do
        expect(updates).to eq(time_estimate: 0)
      end

      it 'returns the remove_estimate message' do
        expect(message).to eq('Removed time estimate.')
      end
    end

    shared_examples 'remove_time_spent command' do
      it 'populates spend_time: :reset if content contains /remove_time_spent' do
        expect(updates).to eq(spend_time: { duration: :reset, user_id: developer.id })
      end

      it 'returns the remove_time_spent message' do
        expect(message).to eq('Removed spent time.')
      end
    end

    shared_examples 'lock command' do
      before do
        issuable.update(discussion_locked: false)
      end

      it 'returns discussion_locked: true if content contains /lock' do
        expect(updates).to eq(discussion_locked: true)
      end

      it 'returns the lock discussion message' do
        expect(message).to eq('Locked the discussion.')
      end
    end

    shared_examples 'unlock command' do
      before do
        issuable.update(discussion_locked: true)
      end

      it 'returns discussion_locked: true if content contains /unlock' do
        expect(updates).to eq(discussion_locked: false)
      end

      it 'returns the unlock discussion message' do
        expect(message).to eq('Unlocked the discussion.')
      end
    end

    shared_examples 'empty command' do |error_msg|
      it 'populates {} if content contains an unsupported command' do
        expect(updates).to be_empty
      end

      it "returns #{error_msg || 'an empty'} message", :aggregate_failures do
        expect(message).to be_empty

        expect(response.warnings).to eq(error_msg) if error_msg
      end
    end

    shared_examples 'merge immediately command' do
      let(:content) { '/merge' }

      it 'runs merge command if content contains /merge' do
        expect(updates).to eq(merge: merge_request.diff_head_sha)
      end

      it 'returns the merge message' do
        expect(message).to eq('Merged this merge request.')
      end
    end

    shared_examples 'merge automatically command' do
      it 'runs merge command if content contains /merge and returns merge message' do
        expect(updates).to eq(merge: merge_request.diff_head_sha)
        expect(message).to eq('Scheduled to merge this merge request (Merge when pipeline succeeds).')
      end
    end

    shared_examples 'award command' do
      it 'toggle award 100 emoji if content contains /award :100:' do
        expect(updates).to eq(emoji_award: "100")
      end

      it 'returns the award message' do
        expect(message).to eq('Toggled :100: emoji award.')
      end
    end

    shared_examples 'duplicate command' do
      before do
        issue_duplicate # populate the issue
      end

      it 'fetches issue and populates canonical_issue_id if content contains /duplicate issue_reference' do
        expect(updates).to eq(canonical_issue_id: issue_duplicate.id)
      end

      it 'returns the duplicate message' do
        expect(message).to eq("Marked this issue as a duplicate of #{issue_duplicate.to_reference(project)}.")
      end
    end

    shared_examples 'copy_metadata command' do
      before do
        source_issuable # populate the issue
        todo_label # populate this label
        inreview_label # populate this label
      end

      it 'fetches issue or merge request and copies labels and milestone if content contains /copy_metadata reference' do
        expect(updates[:add_label_ids]).to match_array([inreview_label.id, todo_label.id])

        if source_issuable.milestone
          expect(updates[:milestone_id]).to eq(source_issuable.milestone.id)
        else
          expect(updates).not_to have_key(:milestone_id)
        end
      end

      it 'returns the copy metadata message' do
        expect(message).to eq("Copied labels and milestone from #{source_issuable.to_reference}.")
      end
    end

    describe 'move issue command' do
      let(:target) { issue }

      context 'valid move' do
        let(:content) { "/move #{project.full_path}" }

        it 'returns the move issue message' do
          expect(message).to eq("Moved this issue to #{project.full_path}.")
        end
      end

      context 'invalid move' do
        let(:content) { '/move invalid' }

        it 'returns move issue failure message when the referenced issue is not found' do
          expect(response.warnings).to eq(_("Failed to move this issue because target project doesn't exist."))
        end
      end
    end

    shared_examples 'confidential command' do
      it 'marks issue as confidential if content contains /confidential' do
        expect(updates).to eq(confidential: true)
      end

      it 'returns the confidential message' do
        expect(message).to eq('Made this issue confidential.')
      end

      context 'when issuable is already confidential' do
        before do
          issuable.update(confidential: true)
        end

        it 'does not return the success message' do
          expect(message).to be_empty
        end

        it 'is not part of the available commands' do
          expect(service.available_commands.pluck(:name)).not_to include(:confidential)
        end
      end
    end

    shared_examples 'shrug command' do
      it 'appends ¯\_(ツ)_/¯ to the comment' do
        expect(response.content).to end_with(shrug)
      end
    end

    shared_examples 'tableflip command' do
      it 'appends (╯°□°)╯︵ ┻━┻ to the comment' do
        expect(response.content).to end_with(table_flip)
      end
    end

    shared_examples 'tag command' do
      it 'tags a commit' do
        expect(updates).to eq(tag_name: tag_name, tag_message: tag_message)
      end

      it 'returns the tag message' do
        if tag_message.present?
          expect(message).to eq(%{Tagged this commit to #{tag_name} with "#{tag_message}".})
        else
          expect(message).to eq("Tagged this commit to #{tag_name}.")
        end
      end
    end

    shared_examples 'assign command' do
      it 'assigns to a single user' do
        expect(updates).to eq(assignee_ids: [developer.id])
      end

      it 'returns the assign message' do
        expect(message).to eq("Assigned #{developer.to_reference}.")
      end
    end

    #################################
    # Here endeth the shared_examples

    describe '/reopen' do
      let(:content) { '/reopen' }

      for_issues_and_merge_requests { it_behaves_like 'reopen command' }
    end

    describe '/close' do
      let(:content) { '/close' }

      for_issues_and_merge_requests { it_behaves_like 'close command' }
    end

    context 'merge command' do
      let(:params) { { merge_request_diff_head_sha: merge_request.diff_head_sha } }
      let(:issuable) { merge_request }
      let(:content) { '/merge' }

      it_behaves_like 'merge immediately command'

      context 'when the head pipeline of merge request is running' do
        before do
          create(:ci_pipeline, :detached_merge_request_pipeline, merge_request: merge_request)
          merge_request.update_head_pipeline
        end

        it_behaves_like 'merge automatically command'
      end

      context 'can not be merged when logged user does not have permissions' do
        let(:current_user) { create(:user) }

        it_behaves_like 'empty command'
      end

      context 'sha does not match' do
        let(:params) { { merge_request_diff_head_sha: 'othersha' } }

        context 'merge_orchestration_service is not available' do
          before do
            stub_feature_flags(merge_orchestration_service: false)
          end

          it_behaves_like 'empty command'
        end

        it 'passes checks and returns merge command' do
          expect(updates).to eq(merge: 'othersha')
          expect(messages).to eq('Merged this merge request.')
        end
      end

      context 'when sha is missing' do
        let(:params) { {} }

        it 'precheck passes and returns merge command' do
          expect(updates).to eq(merge: nil)
        end
      end

      context 'issue can not be merged' do
        let(:issuable) { issue }

        it_behaves_like 'empty command'
      end

      context 'non persisted merge request cant be merged' do
        it_behaves_like 'empty command' do
          let(:issuable) { build(:merge_request) }
        end
      end

      context 'not persisted merge request can not be merged, with source_project' do
        it_behaves_like 'empty command' do
          let(:issuable) { build(:merge_request, source_project: project) }
        end
      end
    end

    describe '/title' do
      context 'with an argument' do
        let(:content) { '/title A brand new title' }

        for_issues_and_merge_requests { it_behaves_like 'title command' }
      end

      context 'with no argument' do
        let(:content) { '/title' }

        it_behaves_like 'empty command' do
          let(:issuable) { issue }
        end
      end
    end

    describe '/assign' do
      let(:issuable) { issue }

      describe 'to one user' do
        let(:content) { "/assign @#{developer.username}" }

        for_issues_and_merge_requests { it_behaves_like 'assign command' }
      end

      # CE does not have multiple assignees
      context 'with multiple assignees' do
        before do
          project.add_developer(developer2)
        end

        let(:content) { "/assign @#{developer.username} @#{developer2.username}" }

        for_issues_and_merge_requests do
          it_behaves_like 'assign command', quarantine: 'https://gitlab.com/gitlab-org/gitlab/-/issues/27989'
        end
      end

      context 'with me alias' do
        let(:content) { '/assign me' }

        for_issues_and_merge_requests { it_behaves_like 'assign command' }
      end

      context 'with me alias and whitespace' do
        let(:content) { '/assign  me ' }

        for_issues_and_merge_requests { it_behaves_like 'assign command' }
      end

      context 'missing user' do
        let(:content) { '/assign @abcd1234' }

        for_issues_and_merge_requests do
          it_behaves_like 'empty command', "Failed to assign a user because no user was found."
        end
      end

      context 'no parameter' do
        let(:content) { '/assign' }

        for_issues_and_merge_requests do
          it_behaves_like 'empty command', "Failed to assign a user because no user was found."
        end
      end
    end

    describe '/unassign' do
      let(:content) { '/unassign' }

      for_issues_and_merge_requests do
        it 'populates assignee_ids: []' do
          issuable.update!(assignee_ids: [developer.id])

          expect(updates).to eq(assignee_ids: [])
        end

        it 'returns the unassign message for all the assignee' do
          issuable.update!(assignee_ids: [developer.id, developer2.id])

          expect(message).to eq("Removed assignees #{developer.to_reference} and #{developer2.to_reference}.")
        end
      end
    end

    describe '/milestone' do
      context 'for an existing milestone' do
        let(:content) { "/milestone %#{milestone.title}" }

        for_issues_and_merge_requests { it_behaves_like 'milestone command' }

        context 'only group milestones available' do
          let_it_be(:ancestor_group) { create(:group) }
          let_it_be(:group) { create(:group, parent: ancestor_group) }
          let_it_be(:descendent_project) { create(:project, :public, :repository, namespace: group) }
          let_it_be(:milestone_10) { create(:milestone, group: ancestor_group, title: '10.0') }
          let(:current_project) { descendent_project }
          let(:milestone) { milestone_10 }

          context 'the issuable is an issue' do
            let(:issuable) { create(:issue, project: current_project) }

            it_behaves_like 'milestone command'
          end

          context 'the issuable is a merge request' do
            let(:issuable) { create(:merge_request, source_project: current_project) }

            it_behaves_like 'milestone command'
          end
        end
      end
    end

    describe '/remove_milestone' do
      let(:content) { '/remove_milestone' }

      for_issues_and_merge_requests { it_behaves_like 'remove_milestone command' }
    end

    describe '/label' do
      context 'multiple labels, single command' do
        let(:content) { %(/label ~"#{inprogress.title}" ~#{bug.title} ~unknown) }

        for_issues_and_merge_requests { it_behaves_like 'label command' }
      end

      for_issues_and_merge_requests do
        it_behaves_like 'multiple label command' do
          let(:content) { %(/label ~"#{inprogress.title}" \n/label ~#{bug.title}) }
        end

        it_behaves_like 'multiple label with same argument' do
          let(:content) { %(/label ~"#{inprogress.title}" \n/label ~#{inprogress.title}) }
        end

        it_behaves_like 'multiword label name starting without ~' do
          let(:content) { %(/label "#{helmchart.title}") }
        end

        it_behaves_like 'multiword label name starting without ~' do
          let(:content) { %(/label "#{helmchart.title}") }
        end

        it_behaves_like 'label name is included in the middle of another label name' do
          let(:content) { %(/label ~"#{helmchart.title}") }
        end

        it_behaves_like 'label name is included in the middle of another label name' do
          let(:content) { %(/label ~"#{helmchart.title}") }
        end
      end
    end

    describe '/unlabel' do
      %i[unlabel remove_label].each do |cmd|
        context "aliased as #{cmd}" do
          for_issues_and_merge_requests do
            context 'a single argument' do
              let(:content) { %(/#{cmd} ~"#{inprogress.title}") }

              it_behaves_like 'unlabel command'
            end

            it_behaves_like 'multiple unlabel command' do
              let(:content) { %(/#{cmd} ~"#{inprogress.title}" \n/#{cmd} ~#{bug.title}) }
            end

            it_behaves_like 'unlabel command with no argument' do
              let(:content) { "/#{cmd}" }
            end
          end
        end
      end
    end

    describe '/relabel' do
      let(:content) { %(/relabel ~"#{inprogress.title}") }

      for_issues_and_merge_requests { it_behaves_like 'relabel command' }
    end

    describe '/done' do
      let(:content) { '/done' }

      for_issues_and_merge_requests { it_behaves_like 'done command' }
    end

    describe '/subscribe' do
      let(:content) { '/subscribe' }

      for_issues_and_merge_requests { it_behaves_like 'subscribe command' }
    end

    describe 'unsubscribe' do
      let(:content) { '/unsubscribe' }

      for_issues_and_merge_requests { it_behaves_like 'unsubscribe command' }
    end

    describe '/remove_due_date' do
      let(:content) { '/remove_due_date' }
      let(:issuable) { issue }

      it_behaves_like 'remove_due_date command'
    end

    describe '/wip' do
      let(:content) { '/wip' }
      let(:issuable) { merge_request }

      it_behaves_like 'wip command'

      it_behaves_like 'unwip command'
    end

    describe '/estimate' do
      let(:issuable) { issue }

      it_behaves_like 'estimate command' do
        let(:content) { '/estimate 1h' }
      end

      it_behaves_like 'empty command' do
        let(:content) { '/estimate' }
      end

      it_behaves_like 'empty command' do
        let(:content) { '/estimate abc' }
      end
    end

    describe '/spend' do
      let(:issuable) { issue }

      it_behaves_like 'spend command' do
        let(:content) { '/spend 1h' }
      end

      it_behaves_like 'spend command with negative time' do
        let(:content) { '/spend -30m' }
      end

      it_behaves_like 'spend command with valid past date' do
        let(:date) { 2.years.ago.to_date }
        let(:content) { "/spend 30m #{date.to_s(:ymd)}" }
      end

      it_behaves_like 'spend command with invalid date'

      it_behaves_like 'spend command with future date'

      it_behaves_like 'empty command' do
        let(:content) { '/spend' }
      end

      it_behaves_like 'empty command' do
        let(:content) { '/spend abc' }
      end
    end

    it_behaves_like 'remove_estimate command' do
      let(:content) { '/remove_estimate' }
      let(:issuable) { issue }
    end

    it_behaves_like 'remove_time_spent command' do
      let(:content) { '/remove_time_spent' }
      let(:issuable) { issue }
    end

    it_behaves_like 'confidential command' do
      let(:content) { '/confidential' }
      let(:issuable) { issue }
    end

    describe '/lock' do
      let(:content) { '/lock' }

      for_issues_and_merge_requests { it_behaves_like 'lock command' }
    end

    describe '/unlock' do
      let(:content) { '/unlock' }

      for_issues_and_merge_requests { it_behaves_like 'unlock command' }
    end

    context '/todo' do
      let(:content) { '/todo' }

      for_issues_and_merge_requests { it_behaves_like 'todo command' }

      context 'if target is a Commit' do
        it_behaves_like 'empty command' do
          let(:target) { commit }
        end
      end
    end

    describe '/due' do
      context 'invalid date' do
        let(:content) { '/due invalid date' }
        let(:target) { build(:issue, project: project) }

        it 'returns invalid date format message when the due date is invalid' do
          expect(message).to be_empty
          expect(response.warnings).to eq(_('Failed to set due date because the date format is invalid.'))
        end
      end

      context 'on an issue' do
        let(:issuable) { issue }

        it_behaves_like 'due command' do
          let(:content) { '/due 2016-08-28' }
        end

        it_behaves_like 'due command' do
          let(:content) { '/due tomorrow' }
          let(:expected_date) { Date.tomorrow }
        end

        it_behaves_like 'due command' do
          let(:content) { '/due 5 days from now' }
          let(:expected_date) { 5.days.from_now.to_date }
        end

        it_behaves_like 'due command' do
          let(:content) { '/due in 2 days' }
          let(:expected_date) { 2.days.from_now.to_date }
        end

        context 'due date is in the past' do
          let(:expected_date) { 1.year.ago.to_date }
          let(:content) { "/due #{expected_date}" }

          it_behaves_like 'due command'
        end
      end

      context 'on a merge request' do
        it_behaves_like 'empty command' do
          let(:content) { '/due 2016-08-28' }
          let(:issuable) { merge_request }
        end
      end
    end

    context '/copy_metadata command' do
      let(:todo_label) { create(:label, project: project, title: 'To Do') }
      let(:inreview_label) { create(:label, project: project, title: 'In Review') }
      let(:target) { issue }

      it 'is available when the user is a developer' do
        expect(service.available_commands).to include(a_hash_including(name: :copy_metadata))
      end

      context 'when the user does not have permission' do
        let(:current_user) { guest }

        it 'is not available' do
          expect(service.available_commands).not_to include(a_hash_including(name: :copy_metadata))
        end
      end

      it_behaves_like 'empty command' do
        let(:content) { '/copy_metadata' }
        let(:issuable) { issue }
      end

      describe '/copy_metadata' do
        let(:source_issuable) { create(:labeled_issue, project: project, labels: [inreview_label, todo_label]) }
        let(:content) { "/copy_metadata #{source_issuable.to_reference}" }

        context 'non-persisted issue' do
          it_behaves_like 'copy_metadata command' do
            let(:issuable) { build(:issue, project: project) }
          end
        end

        context 'persisted issue' do
          it_behaves_like 'copy_metadata command' do
            let(:issuable) { issue }
          end
        end

        context 'when the parent issuable has a milestone' do
          let(:source_issuable) { create(:labeled_issue, project: project, labels: [todo_label, inreview_label], milestone: milestone) }

          it_behaves_like 'copy_metadata command' do
            let(:issuable) { issue }
          end
        end
      end

      context 'when more than one issuable is passed' do
        it_behaves_like 'copy_metadata command' do
          let(:source_issuable) { create(:labeled_issue, project: project, labels: [inreview_label, todo_label]) }
          let(:other_label) { create(:label, project: project, title: 'Other') }
          let(:other_source_issuable) { create(:labeled_issue, project: project, labels: [other_label]) }

          let(:content) { "/copy_metadata #{source_issuable.to_reference} #{other_source_issuable.to_reference}" }
          let(:issuable) { issue }
        end
      end

      context 'cross project references' do
        it_behaves_like 'empty command' do
          let(:other_project) { create(:project, :public) }
          let(:source_issuable) { create(:labeled_issue, project: other_project, labels: [todo_label, inreview_label]) }
          let(:content) { "/copy_metadata #{source_issuable.to_reference(project)}" }
          let(:issuable) { issue }
        end

        it_behaves_like 'empty command' do
          let(:content) { "/copy_metadata imaginary##{non_existing_record_iid}" }
          let(:issuable) { issue }
        end

        it_behaves_like 'empty command' do
          let(:other_project) { private_project }
          let(:source_issuable) { create(:issue, project: other_project) }

          let(:content) { "/copy_metadata #{source_issuable.to_reference(project)}" }
          let(:issuable) { issue }
        end
      end
    end

    context '/duplicate command' do
      let(:issuable) { issue }

      it_behaves_like 'duplicate command' do
        let(:issue_duplicate) { create(:issue, project: issue.project) }
        let(:content) { "/duplicate #{issue_duplicate.to_reference}" }
      end

      it_behaves_like 'empty command' do
        let(:content) { '/duplicate' }
      end

      context 'cross project references' do
        it_behaves_like 'duplicate command' do
          let(:other_project) { create(:project, :public) }
          let(:issue_duplicate) { create(:issue, project: other_project) }
          let(:content) { "/duplicate #{issue_duplicate.to_reference(project)}" }
        end

        it_behaves_like 'empty command', _('Failed to mark this issue as a duplicate because referenced issue was not found.') do
          let(:content) { "/duplicate imaginary##{non_existing_record_iid}" }
        end

        it_behaves_like 'empty command', _('Failed to mark this issue as a duplicate because referenced issue was not found.') do
          let(:other_project) { private_project }
          let(:issue_duplicate) { create(:issue, project: other_project) }

          let(:content) { "/duplicate #{issue_duplicate.to_reference(project)}" }
        end
      end
    end

    context 'when current_user cannot :admin_issue' do
      let_it_be(:visitor) { create(:user) }
      let_it_be(:visitors_issue) { create(:issue, project: project, author: visitor) }

      let(:current_user) { visitor }
      let(:issuable) { visitors_issue }

      it_behaves_like 'empty command' do
        let(:content) { "/assign @#{developer.username}" }
      end

      it_behaves_like 'empty command' do
        let(:content) { '/unassign' }
      end

      it_behaves_like 'empty command' do
        let(:content) { "/milestone %#{milestone.title}" }
      end

      it_behaves_like 'empty command' do
        let(:content) { '/remove_milestone' }
      end

      it_behaves_like 'empty command' do
        let(:content) { %(/label ~"#{inprogress.title}" ~#{bug.title} ~unknown) }
      end

      it_behaves_like 'empty command' do
        let(:content) { %(/unlabel ~"#{inprogress.title}") }
      end

      it_behaves_like 'empty command' do
        let(:content) { %(/relabel ~"#{inprogress.title}") }
      end

      it_behaves_like 'empty command' do
        let(:content) { '/due tomorrow' }
      end

      it_behaves_like 'empty command' do
        let(:content) { '/remove_due_date' }
      end

      it_behaves_like 'empty command' do
        let(:content) { '/confidential' }
      end

      it_behaves_like 'empty command' do
        let(:content) { '/lock' }
      end

      it_behaves_like 'empty command' do
        let(:content) { '/unlock' }
      end
    end

    context '/award' do
      context 'with an argument' do
        let(:content) { '/award :100:' }

        for_issues_and_merge_requests { it_behaves_like 'award command' }

        context 'if target is a Commit' do
          let(:target) { commit }

          it_behaves_like 'empty command'
        end
      end

      context 'with no argument' do
        it_behaves_like 'empty command' do
          let(:content) { '/award' }
          let(:issuable) { issue }
        end
      end

      context 'with non-existing / invalid  emojis' do
        it_behaves_like 'empty command' do
          let(:content) { '/award noop' }
          let(:issuable) { issue }
        end

        it_behaves_like 'empty command' do
          let(:content) { '/award :lorem_ipsum:' }
          let(:issuable) { issue }
        end
      end
    end

    context '/shrug command' do
      let(:issuable) { issue }

      it_behaves_like 'shrug command' do
        let(:content) { '/shrug people are people' }
      end

      it_behaves_like 'shrug command' do
        let(:content) { '/shrug' }
      end
    end

    describe '/cc' do
      let(:content) { '/cc @foo' }

      for_issues_and_merge_requests do
        it 'does not create any updates' do
          expect(updates).to be_empty
        end

        it 'does not change the content' do
          expect(response.content).to eq(content)
        end

        it 'does not even count as a command' do
          expect(response.count).to be_zero
        end

        it 'is available' do
          expect(service.available_commands.pluck(:name)).to include(:cc)
        end
      end
    end

    context '/tableflip command' do
      let(:issuable) { issue }

      it_behaves_like 'tableflip command' do
        let(:content) { '/tableflip curse your sudden but inevitable betrayal' }
      end

      it_behaves_like 'tableflip command' do
        let(:content) { '/tableflip' }
      end
    end

    context '/target_branch command' do
      let(:target_branch) { 'merge-test' }

      let(:content) { "/target_branch #{target_branch}" }
      let(:target) { merge_request }

      it 'updates target_branch if /target_branch command is executed' do
        expect(updates).to eq(target_branch: target_branch)
      end

      it 'returns the target_branch message' do
        expect(message).to eq('Set target branch to merge-test.')
      end

      context 'blanks around param' do
        let(:target_branch) { '    merge-test      ' }

        it 'strips them' do
          expect(updates).to eq(target_branch: target_branch.strip)
        end
      end

      context 'with no argument' do
        let(:content) { '/target_branch' }

        it_behaves_like 'empty command'
      end

      context 'target branch does not exist' do
        let(:content) { '/target_branch totally_non_existing_branch' }

        it_behaves_like 'empty command', 'No branch named totally_non_existing_branch.'
      end
    end

    context '/board_move command' do
      include_context 'board context'

      let(:content) { %{/board_move ~"#{inreview.title}"} }
      let(:target) { issue }

      it 'populates remove_label_ids for all current board columns' do
        issue.update!(label_ids: [todo.id, inprogress.id])

        expect(updates[:remove_label_ids]).to match_array([todo.id, inprogress.id])
      end

      it 'populates add_label_ids with the id of the given label' do
        expect(updates[:add_label_ids]).to eq([inreview.id])
      end

      it 'does not include the given label id in remove_label_ids' do
        issue.update!(label_ids: [todo.id, inreview.id])

        expect(updates[:remove_label_ids]).to match_array([todo.id])
      end

      it 'does not remove label ids that are not lists on the board' do
        issue.update!(label_ids: [todo.id, bug.id])

        expect(updates[:remove_label_ids]).to match_array([todo.id])
      end

      it 'returns board_move message' do
        issue.update!(label_ids: [todo.id, inprogress.id])

        expect(message).to eq("Moved issue to ~#{inreview.id} column in the board.")
      end

      context 'if the project has multiple boards' do
        before do
          create(:board, project: project)
        end

        it_behaves_like 'empty command'
      end

      context 'if the given label does not exist' do
        let(:content) { '/board_move ~"Fake Label"' }

        it_behaves_like 'empty command', 'Failed to move this issue because label was not found.'
      end

      context 'if multiple labels are given' do
        let(:content) { %{/board_move ~"#{inreview.title}" ~"#{todo.title}"} }

        it_behaves_like 'empty command', 'Failed to move this issue because only a single label can be provided.'
      end

      context 'if the given label is not a list on the board' do
        let(:content) { %{/board_move ~"#{bug.title}"} }

        it_behaves_like 'empty command', 'Failed to move this issue because label was not found.'
      end

      context 'if target is not an Issue' do
        let(:target) { merge_request }

        it_behaves_like 'empty command'
      end
    end

    describe '/tag' do
      let(:target) { commit }

      context 'with no argument' do
        let(:content) { '/tag' }

        it_behaves_like 'empty command'
      end

      context 'tags a commit with a tag name' do
        it_behaves_like 'tag command' do
          let(:tag_name) { 'v1.2.3' }
          let(:tag_message) { nil }
          let(:content) { "/tag #{tag_name}" }
        end
      end

      context 'tags a commit with a tag name and message' do
        it_behaves_like 'tag command' do
          let(:tag_name) { 'v1.2.3' }
          let(:tag_message) { 'Stable release' }
          let(:content) { "/tag #{tag_name} #{tag_message}" }
        end
      end
    end

    describe 'use of :only' do
      let(:content) { ['/shrug test', '/close'].join("\n") }

      for_issues_and_merge_requests do
        it 'limits to commands passed ' do
          expect(service.execute(only: [:shrug])).to have_attributes(
            updates: be_empty,
            content: eq("test #{shrug}\n/close")
          )
        end
      end
    end

    describe 'leading whitespace' do
      let(:target) { issue }
      let(:content) { " - list\n\n/close\n\ntest\n\n" }

      it 'is preserved' do
        expect(response.content).to eq(" - list\n\ntest")
      end
    end

    describe '/zoom' do
      let(:url) { 'https://foo.zoom.us/s/a' }
      let(:content) { "/zoom #{url}" }

      context 'the url is bad' do
        let(:url) { 'not a zoom url' }
        let(:target) { issue }

        it_behaves_like 'empty command'
      end

      context 'the issue is persisted' do
        let(:target) { issue }

        it 'does not include updates' do
          expect(updates).to be_empty
        end

        it 'creates a zoom meeting linked to the issue' do
          expect { response }.to change(ZoomMeeting, :count).by(1)

          expect(ZoomMeeting.canonical(issue).where(url: url)).to exist
        end
      end

      context 'the issue is new' do
        let(:target) { build(:issue, author: current_user, project: current_project) }

        it 'includes updates' do
          meeting = have_attributes(class: ZoomMeeting,
                                    issue_status: 'added',
                                    issue: target,
                                    url: url)

          expect(updates).to match(a_hash_including(zoom_meetings: contain_exactly(meeting)))
        end
      end

      context 'for a merge request' do
        let(:target) { merge_request }

        it_behaves_like 'empty command'
      end
    end

    describe '/remove_zoom' do
      let(:issuable) { issue }
      let(:meeting) { create(:zoom_meeting, issue: issue) }
      let(:content) { '/remove_zoom' }

      it 'does not include updates' do
        expect(updates).to be_empty
      end

      it 'removes the meeting' do
        expect { response }.not_to change(ZoomMeeting, :count)

        expect(ZoomMeeting.canonical(issue)).not_to exist
      end

      context 'for a merge request' do
        let(:target) { merge_request }

        it_behaves_like 'empty command'
      end
    end

    describe '/create_merge_request' do
      let(:issuable) { issue }
      let(:iid) { issue.iid }

      shared_examples 'when we cannot use this command' do
        context 'if issuable is not an Issue' do
          let(:issuable) { merge_request }

          it_behaves_like 'empty command'
        end

        context "when logged user cannot create_merge_requests in the project" do
          let(:current_project) { create(:project, :archived) }

          it_behaves_like 'empty command'
        end

        context 'when logged user cannot push code to the project' do
          let(:current_project) { private_project }
          let(:current_user) { build_stubbed(:user) }

          it_behaves_like 'empty command'
        end
      end

      context 'without a branch_name' do
        let(:content) { '/create_merge_request' }

        include_examples 'when we cannot use this command'

        it 'populates create_merge_request with branch_name and issue iid' do
          expect(updates).to eq(create_merge_request: { branch_name: nil, issue_iid: iid })
        end

        it 'returns the create_merge_request message' do
          expect(message).to eq("Created a branch and a merge request to resolve this issue.")
        end
      end

      context 'with a branch name' do
        let(:branch_name) { '1-feature' }
        let(:content) { "/create_merge_request #{branch_name}" }

        include_examples 'when we cannot use this command'

        it 'populates create_merge_request with branch_name and issue iid' do
          expect(updates).to eq(create_merge_request: { branch_name: branch_name, issue_iid: iid })
        end

        it 'returns the create_merge_request message' do
          expect(message).to eq("Created branch '#{branch_name}' and a merge request to resolve this issue.")
        end
      end
    end

    context 'submit_review command' do
      where(:note) do
        [
          'I like it',
          '/submit_review'
        ]
      end

      with_them do
        let(:content) { '/submit_review' }
        let!(:draft_note) { create(:draft_note, note: note, merge_request: merge_request, author: developer) }

        it 'submits the users current review' do
          _, _, message = service.execute(content, merge_request)

          expect { draft_note.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(message).to eq('Submitted the current review.')
        end
      end
    end

    describe '/zoom' do
      let(:target) { issue }

      shared_examples 'a failure to add a zoom link' do
        it 'does not add a zoom link' do
          expect(ZoomMeeting.canonical_meeting_url(issue)).to be_nil
        end
      end

      shared_examples 'adding a zoom link' do
        it 'sets the message correctly' do
          expect(message).to eq('Zoom meeting added')
        end

        it 'does not warn' do
          expect(response.warnings).to be_empty
        end
      end

      context 'no parameter' do
        let(:content) { '/zoom' }

        it_behaves_like 'empty command'
        it_behaves_like 'a failure to add a zoom link'
      end

      context 'with an invalid parameter' do
        let(:content) { '/zoom foo' }

        it_behaves_like 'empty command', 'Failed to add a Zoom meeting'
        it_behaves_like 'a failure to add a zoom link'
      end

      context 'with a valid looking zoom link' do
        let(:zoom_link) { 'https://zoom.us/j/123456789' }
        let(:content) { "/zoom #{zoom_link}" }

        it_behaves_like 'adding a zoom link'

        it 'adds a zoom link' do
          response

          expect(ZoomMeeting.canonical_meeting_url(issue)).to eq(zoom_link)
        end

        it 'sets the updates correctly' do
          expect(updates).to be_empty
        end

        context 'the issue is new' do
          let(:target) { build(:issue, project: issue.project, author: issue.author) }

          it_behaves_like 'adding a zoom link'

          it 'sets the updates correctly' do
            expect(updates).to match(zoom_meetings: contain_exactly(ZoomMeeting))
          end
        end

        context 'for a merge request' do
          let(:target) { merge_request }

          it_behaves_like 'empty command'
        end
      end

      describe '/remove_zoom' do
        let(:target) { issue }
        let(:content) { '/remove_zoom' }

        context 'there is a meeting' do
          let_it_be(:meeting) { create(:zoom_meeting, issue: issue) }

          it 'removes the canonical meeting' do
            response

            expect(ZoomMeeting.canonical_meeting_url(issue)).to be_nil
          end
          it 'provides a suitable message' do
            expect(message).to eq('Zoom meeting removed')
          end
        end

        context 'there is no meeting' do
          it_behaves_like 'empty command', 'Failed to apply one command.'
        end

        context 'for a merge request' do
          let(:target) { merge_request }

          it_behaves_like 'empty command'
        end
      end
    end
  end

  describe '#explain' do
    let(:explanations) { service.explain.messages }
    let(:merge_request) { basic_mr }

    shared_examples 'a correct explanation' do
      it 'has the correct explanations' do
        expect(explanations).to contain_exactly(explanation)
      end
    end

    describe 'close command' do
      let(:content) { '/close' }

      context 'on an issue' do
        let(:target) { issue }

        it_behaves_like 'a correct explanation' do
          let(:explanation) { 'Closes this issue.' }
        end
      end

      context 'on a merge request' do
        let(:target) { merge_request }

        it_behaves_like 'a correct explanation' do
          let(:explanation) { 'Closes this merge request.' }
        end
      end
    end

    describe 'reopen command' do
      let(:content) { '/reopen' }

      before do
        target.close!
      end

      context 'on an issue' do
        let(:target) { issue }

        it_behaves_like 'a correct explanation' do
          let(:explanation) { 'Reopens this issue.' }
        end
      end

      context 'on a merge request' do
        let(:target) { merge_request }

        it_behaves_like 'a correct explanation' do
          let(:explanation) { 'Reopens this merge request.' }
        end
      end
    end

    describe 'title command' do
      let(:content) { '/title This is new title' }

      for_issues_and_merge_requests do
        it_behaves_like 'a correct explanation' do
          let(:explanation) { 'Changes the title to "This is new title".' }
        end
      end
    end

    describe 'assign command' do
      let(:content) { "/assign @#{developer.username} do it!" }

      for_issues_and_merge_requests do
        it_behaves_like 'a correct explanation' do
          let(:explanation) { "Assigns @#{developer.username}." }
        end
      end
    end

    describe 'unassign command' do
      let(:content) { '/unassign' }

      before do
        target.update!(assignee_ids: [developer.id])
      end

      for_issues_and_merge_requests do
        it_behaves_like 'a correct explanation' do
          let(:explanation) { "Removes assignee @#{developer.username}." }
        end
      end
    end

    context 'milestone command with wrong reference' do
      let(:content) { '/milestone %wrong-milestone' }
      let(:target) { issue }

      it 'is empty' do
        expect(explanations).to be_empty
      end
    end

    describe 'remove milestone command' do
      let(:content) { '/remove_milestone' }
      let(:target) { merge_request }

      before do
        target.update(milestone: milestone)
      end

      it_behaves_like 'a correct explanation' do
        let(:explanation) { %(Removes %"#{milestone.title}" milestone.) }
      end
    end

    describe 'label command with missing label' do
      let(:content) { '/label ~missing' }
      let(:target) { issue }

      it 'is empty' do
        expect(explanations).to be_empty
      end
    end

    describe 'unlabel command with no parameters' do
      let(:content) { '/unlabel' }
      let(:target) { merge_request }

      before do
        merge_request.update!(label_ids: [bug.id])
      end

      it_behaves_like 'a correct explanation' do
        let(:explanation) { _('Removes all labels.') }
      end
    end

    describe 'relabel command with a label' do
      let(:content) { '/relabel Bug' }
      let(:feature) { create(:label, project: project, title: 'Feature') }
      let(:target) { issue }

      before do
        issue.update!(label_ids: [feature.id])
      end

      it_behaves_like 'a correct explanation' do
        let(:explanation) { "Replaces all labels with ~#{bug.id} label." }
      end
    end

    describe 'subscribe command' do
      let(:content) { '/subscribe' }

      context 'on an issue' do
        let(:target) { issue }

        it_behaves_like 'a correct explanation' do
          let(:explanation) { 'Subscribes to this issue.' }
        end
      end

      context 'on a merge request' do
        let(:target) { merge_request }

        it_behaves_like 'a correct explanation' do
          let(:explanation) { 'Subscribes to this merge request.' }
        end
      end
    end

    describe 'unsubscribe command' do
      let(:content) { '/unsubscribe' }

      before do
        target.subscribe(current_user, current_project)
      end

      context 'on an issue' do
        let(:target) { issue }

        it_behaves_like 'a correct explanation' do
          let(:explanation) { 'Unsubscribes from this issue.' }
        end
      end

      context 'on a merge request' do
        let(:target) { merge_request }

        it_behaves_like 'a correct explanation' do
          let(:explanation) { 'Unsubscribes from this merge request.' }
        end
      end
    end

    describe 'due command with a date' do
      let(:content) { '/due April 1st 2016' }
      let(:target) { issue }

      it_behaves_like 'a correct explanation' do
        let(:explanation) { 'Sets the due date to Apr 1, 2016.' }
      end
    end

    describe 'wip command' do
      let(:content) { '/wip' }
      let(:target) { merge_request }

      it_behaves_like 'a correct explanation' do
        let(:explanation) { 'Marks this merge request as Work In Progress.' }
      end
    end

    describe 'award command with emoji' do
      let(:content) { '/award :confetti_ball: ' }
      let(:target) { issue }

      it_behaves_like 'a correct explanation' do
        let(:explanation) { 'Toggles :confetti_ball: emoji award.' }
      end
    end

    describe 'estimate command' do
      let(:content) { '/estimate 79d' }
      let(:target) { merge_request }

      it_behaves_like 'a correct explanation' do
        let(:explanation) { 'Sets time estimate to 3mo 3w 4d.' }
      end
    end

    describe 'spend command' do
      let(:content) { '/spend -120m' }
      let(:target) { issue }

      it_behaves_like 'a correct explanation' do
        let(:explanation) { 'Subtracts 2h spent time.' }
      end
    end

    describe 'target branch command' do
      let(:content) { '/target_branch my-feature ' }
      let(:target) { merge_request }

      it_behaves_like 'a correct explanation' do
        let(:explanation) { 'Sets target branch to my-feature.' }
      end
    end

    describe 'board move command' do
      include_context 'board context'

      let(:content) { %(/board_move ~"#{inreview.title}") }
      let(:target) { issue }

      it_behaves_like 'a correct explanation' do
        let(:explanation) { "Moves issue to ~#{inreview.id} column in the board." }
      end
    end

    describe 'move issue to another project command' do
      let(:content) { '/move test/project' }
      let(:target) { issue }

      it_behaves_like 'a correct explanation' do
        let(:explanation) { "Moves this issue to test/project." }
      end
    end

    describe 'tag a commit' do
      let(:target) { commit }

      context 'with a tag name' do
        context 'without a message' do
          let(:content) { '/tag v1.2.3' }

          it_behaves_like 'a correct explanation' do
            let(:explanation) { "Tags this commit to v1.2.3." }
          end
        end

        context 'with an empty message' do
          let(:content) { '/tag v1.2.3 ' }

          it_behaves_like 'a correct explanation' do
            let(:explanation) { "Tags this commit to v1.2.3." }
          end
        end
      end

      describe 'with a tag name and message' do
        let(:content) { '/tag v1.2.3 Stable release' }

        it_behaves_like 'a correct explanation' do
          let(:explanation) { "Tags this commit to v1.2.3 with \"Stable release\"." }
        end
      end
    end

    describe 'create a merge request' do
      let(:target) { issue }

      context 'with no branch name' do
        let(:content) { '/create_merge_request' }
        let(:explanation) { _('Creates a branch and a merge request to resolve this issue.') }

        it_behaves_like 'a correct explanation'
      end

      context 'with a branch name' do
        let(:content) { '/create_merge_request foo' }
        let(:explanation) { "Creates branch 'foo' and a merge request to resolve this issue." }

        it_behaves_like 'a correct explanation'
      end
    end
  end

  describe "#commands_executed_count" do
    let(:target) { issue }
    let(:content) { "/close and \n/assign me and \n/title new title\n and /label ~missing" }

    let(:response) { service.execute }

    it 'counts commands executed' do
      service.execute

      expect(service.commands_executed_count).to eq(3)
    end

    it 'is the same as response.count' do
      expect(response.count).to eq(3)
    end

    context 'no commands are executed' do
      let(:target) { basic_mr }
      let(:content) { "/close and \n/create_merge_request me" }

      before do
        basic_mr.close!
      end

      it 'executes no commands' do
        expect(response.count).to be_zero
        expect(service.commands_executed_count).to be_zero
      end
    end
  end
end
