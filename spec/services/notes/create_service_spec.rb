# frozen_string_literal: true

require 'spec_helper'

describe Notes::CreateService do
  set(:project) { create(:project, :repository) }
  set(:issue) { create(:issue, project: project) }
  set(:user) { create(:user) }
  let(:opts) do
    { note: 'Awesome comment', noteable_type: 'Issue', noteable_id: issue.id }
  end

  describe '#execute' do
    before do
      project.add_maintainer(user)
    end

    context "valid params" do
      it 'returns a valid note' do
        note = described_class.new(project, user, opts).execute

        expect(note).to be_valid
      end

      it 'returns a persisted note' do
        note = described_class.new(project, user, opts).execute

        expect(note).to be_persisted
      end

      it 'note has valid content' do
        note = described_class.new(project, user, opts).execute

        expect(note.note).to eq(opts[:note])
      end

      it 'note belongs to the correct project' do
        note = described_class.new(project, user, opts).execute

        expect(note.project).to eq(project)
      end

      it 'TodoService#new_note is called' do
        note = build(:note, project: project)
        allow(Note).to receive(:new).with(opts) { note }

        expect_any_instance_of(TodoService).to receive(:new_note).with(note, user)

        described_class.new(project, user, opts).execute
      end

      it 'enqueues NewNoteWorker' do
        note = build(:note, id: 999, project: project)
        allow(Note).to receive(:new).with(opts) { note }

        expect(NewNoteWorker).to receive(:perform_async).with(note.id)

        described_class.new(project, user, opts).execute
      end
    end

    context 'noteable highlight cache clearing' do
      let(:project_with_repo) { create(:project, :repository) }
      let(:merge_request) do
        create(:merge_request, source_project: project_with_repo,
                               target_project: project_with_repo)
      end

      let(:position) do
        Gitlab::Diff::Position.new(old_path: "files/ruby/popen.rb",
                                   new_path: "files/ruby/popen.rb",
                                   old_line: nil,
                                   new_line: 14,
                                   diff_refs: merge_request.diff_refs)
      end

      let(:new_opts) do
        opts.merge(in_reply_to_discussion_id: nil,
                   type: 'DiffNote',
                   noteable_type: 'MergeRequest',
                   noteable_id: merge_request.id,
                   position: position.to_h)
      end

      before do
        allow_any_instance_of(Gitlab::Diff::Position)
          .to receive(:unfolded_diff?) { true }
      end

      it 'clears noteable diff cache when it was unfolded for the note position' do
        expect_any_instance_of(Gitlab::Diff::HighlightCache).to receive(:clear)

        described_class.new(project_with_repo, user, new_opts).execute
      end

      it 'does not clear cache when note is not the first of the discussion' do
        prev_note =
          create(:diff_note_on_merge_request, noteable: merge_request,
                                              project: project_with_repo)
        reply_opts =
          opts.merge(in_reply_to_discussion_id: prev_note.discussion_id,
                     type: 'DiffNote',
                     noteable_type: 'MergeRequest',
                     noteable_id: merge_request.id,
                     position: position.to_h)

        expect(merge_request).not_to receive(:diffs)

        described_class.new(project_with_repo, user, reply_opts).execute
      end
    end

    context 'note diff file' do
      let(:project_with_repo) { create(:project, :repository) }
      let(:merge_request) do
        create(:merge_request,
               source_project: project_with_repo,
               target_project: project_with_repo)
      end
      let(:line_number) { 14 }
      let(:position) do
        Gitlab::Diff::Position.new(old_path: "files/ruby/popen.rb",
                                   new_path: "files/ruby/popen.rb",
                                   old_line: nil,
                                   new_line: line_number,
                                   diff_refs: merge_request.diff_refs)
      end
      let(:previous_note) do
        create(:diff_note_on_merge_request, noteable: merge_request, project: project_with_repo)
      end

      before do
        project_with_repo.add_maintainer(user)
      end

      context 'when eligible to have a note diff file' do
        let(:new_opts) do
          opts.merge(in_reply_to_discussion_id: nil,
                     type: 'DiffNote',
                     noteable_type: 'MergeRequest',
                     noteable_id: merge_request.id,
                     position: position.to_h)
        end

        it 'note is associated with a note diff file' do
          note = described_class.new(project_with_repo, user, new_opts).execute

          expect(note).to be_persisted
          expect(note.note_diff_file).to be_present
        end
      end

      context 'when DiffNote is a reply' do
        let(:new_opts) do
          opts.merge(in_reply_to_discussion_id: previous_note.discussion_id,
                     type: 'DiffNote',
                     noteable_type: 'MergeRequest',
                     noteable_id: merge_request.id,
                     position: position.to_h)
        end

        it 'note is not associated with a note diff file' do
          note = described_class.new(project_with_repo, user, new_opts).execute

          expect(note).to be_persisted
          expect(note.note_diff_file).to be_nil
        end

        context 'when DiffNote from an image' do
          let(:image_position) do
            Gitlab::Diff::Position.new(old_path: "files/images/6049019_460s.jpg",
                                       new_path: "files/images/6049019_460s.jpg",
                                       width: 100,
                                       height: 100,
                                       x: 1,
                                       y: 100,
                                       diff_refs: merge_request.diff_refs,
                                       position_type: 'image')
          end

          let(:new_opts) do
            opts.merge(in_reply_to_discussion_id: nil,
                       type: 'DiffNote',
                       noteable_type: 'MergeRequest',
                       noteable_id: merge_request.id,
                       position: image_position.to_h)
          end

          it 'note is not associated with a note diff file' do
            note = described_class.new(project_with_repo, user, new_opts).execute

            expect(note).to be_persisted
            expect(note.note_diff_file).to be_nil
          end
        end
      end
    end

    context 'note with commands' do
      context 'all quick actions' do
        QuickAction = Struct.new(:action_text, :expectation) do
          def skip_access_check
            action_text["/todo"] ||
              action_text["/done"] ||
              action_text["/subscribe"] ||
              action_text["/shrug"] ||
              action_text["/tableflip"]
          end
        end

        set(:milestone) { create(:milestone, project: project, title: "sprint") }
        set(:label) { create(:label, project: project, title: 'bug') }
        set(:label_1) { create(:label, project: project, title: 'to be copied') }
        set(:label_2) { create(:label, project: project, title: 'feature') }
        set(:issue) { create(:issue, project: project, labels: [label]) }
        set(:issue_2) { create(:issue, project: project, labels: [label, label_1]) }

        # Quick actions shared by issues and merge requests
        let(:issuable_quick_actions) do
          [
            QuickAction.new("/subscribe", ->(noteable, can_use_quick_action) {
              user = try(:non_member) || try(:developer)

              expect(noteable.subscribed?(user, issuable.project)).to eq(can_use_quick_action)
            }),
            QuickAction.new("/unsubscribe", ->(noteable, can_use_quick_action) {
              user = try(:non_member) || try(:developer)

              expect(noteable.subscribed?(user, issuable.project)).to eq(false)
            }),
            QuickAction.new("/todo", ->(noteable, can_use_quick_action) {
              expect(noteable.todos.count == 1).to eq(can_use_quick_action)
            }),
            QuickAction.new("/done", ->(noteable, can_use_quick_action) {
              expect(noteable.todos.last.done? == true).to eq(can_use_quick_action)
            }),
            QuickAction.new("/close", ->(noteable, can_use_quick_action) {
              expect(noteable.closed? == true).to eq(can_use_quick_action)
            }),
            QuickAction.new("/reopen", ->(noteable, can_use_quick_action) {
              if can_use_quick_action
                expect(noteable.opened?).to eq(true)
              else
                expect(noteable.opened?).to eq(true)
                expect(noteable.saved_change_to_state?).to eq(false)
              end
            }),
            QuickAction.new("/assign @#{user.username}", ->(noteable, can_use_quick_action) {
              expect(noteable.assignees == [user]).to eq(can_use_quick_action)
            }),
            QuickAction.new("/unassign", ->(noteable, can_use_quick_action) {
              expect(noteable.assignees.empty?).to eq(can_use_quick_action)
            }),
            QuickAction.new("/title new title", ->(noteable, can_use_quick_action) {
              expect(noteable.title == "new title").to eq(can_use_quick_action)
            }),
            QuickAction.new("/lock", ->(noteable, can_use_quick_action) {
              expect(noteable.discussion_locked == true).to eq(can_use_quick_action)
            }),
            QuickAction.new("/unlock", ->(noteable, can_use_quick_action) {
              if can_use_quick_action
                expect(noteable.discussion_locked).to eq(false)
              else
                expect(noteable.saved_change_to_discussion_locked?).to eq(false)
              end
            }),
            QuickAction.new("/milestone %\"sprint\"", ->(noteable, can_use_quick_action) {
              expect(noteable.milestone == milestone).to eq(can_use_quick_action)
            }),
            QuickAction.new("/remove_milestone", ->(noteable, can_use_quick_action) {
              if can_use_quick_action
                expect(noteable.milestone_id).to be_nil
              else
                expect(noteable.saved_change_to_milestone_id?).to eq(false)
              end
            }),
            QuickAction.new("/label ~feature", ->(noteable, can_use_quick_action) {
              expect(noteable.labels&.last&.id == label_2.id).to eq(can_use_quick_action)
            }),
            QuickAction.new("/unlabel", ->(noteable, can_use_quick_action) {
              if can_use_quick_action
                expect(noteable.labels).to be_empty
              else
                expect(noteable.labels).to be_present
              end
            }),
            QuickAction.new("/award :100:", ->(noteable, can_use_quick_action) {
              expect(noteable.award_emoji&.last&.name == "100").to eq(can_use_quick_action)
            }),
            QuickAction.new("/estimate 1d 2h 3m", ->(noteable, can_use_quick_action) {
              expect(noteable.time_estimate == 36180).to eq(can_use_quick_action)
            }),
            QuickAction.new("/remove_estimate", ->(noteable, can_use_quick_action) {
              if can_use_quick_action
                expect(noteable.time_estimate).to be_zero
              else
                expect(noteable.saved_change_to_time_estimate?).to eq(false)
              end
            }),
            QuickAction.new("/spend 1d 2h 3m", ->(noteable, can_use_quick_action) {
              expect(noteable.total_time_spent == 36180).to eq(can_use_quick_action)
            }),
            QuickAction.new("/remove_time_spent", ->(noteable, can_use_quick_action) {
              if can_use_quick_action
                expect(noteable.total_time_spent == 0)
              else
                expect(noteable.timelogs).to be_empty
              end
            }),
            QuickAction.new("/shrug oops", ->(noteable, can_use_quick_action) {
              expect(noteable.notes&.last&.note == "HELLO\noops ¯\\＿(ツ)＿/¯\nWORLD").to eq(can_use_quick_action)
            }),
            QuickAction.new("/tableflip oops", ->(noteable, can_use_quick_action) {
              expect(noteable.notes&.last&.note == "HELLO\noops (╯°□°)╯︵ ┻━┻\nWORLD").to eq(can_use_quick_action)
            }),
            QuickAction.new("/copy_metadata #{issue_2.to_reference}", ->(noteable, can_use_quick_action) {
              expect(noteable.labels == issue_2.labels).to eq(can_use_quick_action)
            })
          ]
        end

        shared_examples 'issuable quick actions' do
          let(:old_assignee) { create(:user) }

          before do
            project.add_developer(old_assignee)
            issuable.update(assignees: [old_assignee])
          end

          context 'when user can update issuable' do
            set(:developer) { create(:user) }

            before do
              project.add_developer(developer)
            end

            it 'saves the note and updates the issue' do
              quick_actions.each do |quick_action|
                note_text = %(HELLO\n#{quick_action.action_text}\nWORLD)

                note = described_class.new(project, developer, note_params.merge(note: note_text)).execute
                noteable = note.noteable

                # shrug and tablefip quick actions modifies the note text
                # on these cases we need to skip this assertion
                if !quick_action.action_text["shrug"] && !quick_action.action_text["tableflip"]
                  expect(note.note).to eq "HELLO\nWORLD"
                end

                quick_action.expectation.call(noteable, true)
              end
            end
          end

          context 'when user cannot update issuable' do
            set(:non_member) { create(:user) }

            it 'applies commands that user can execute' do
              quick_actions.each do |quick_action|
                note_text = %(HELLO\n#{quick_action.action_text}\nWORLD)

                note = described_class.new(project, non_member, note_params.merge(note: note_text)).execute
                noteable = note.noteable

                if quick_action.skip_access_check
                  quick_action.expectation.call(noteable, true)
                else
                  quick_action.expectation.call(noteable, false)
                end
              end
            end
          end
        end

        context 'for issues' do
          let(:issuable) { issue }
          let(:note_params) { opts }
          let(:issue_quick_actions) do
            [
              # QuickAction.new("/confidential", "confidential", true),
              # QuickAction.new("/due 2016-08-28", "due_date", Date.new(2016, 8, 28)),
              # QuickAction.new("/remove_due_date", "due_date", nil),
              # QuickAction.new("/duplicate #{issue_2.to_reference}", "closed?", true)
            ]
          end
          let(:quick_actions) { issuable_quick_actions + issue_quick_actions }

          it_behaves_like 'issuable quick actions'
        end

        context 'for merge requests' do
          set(:merge_request) { create(:merge_request, source_project: project, labels: [label]) }
          let(:issuable) { merge_request }
          let(:note_params) { opts.merge(noteable_type: 'MergeRequest', noteable_id: merge_request.id) }
          let(:merge_request_quick_actions) do
            [
              # QuickAction.new("/target_branch fix", "target_branch", "fix"),
              # QuickAction.new("/wip", "work_in_progress?", true),
              # QuickAction.new("/wip", "work_in_progress?", false)
            ]
          end
          let(:quick_actions) { issuable_quick_actions + merge_request_quick_actions }

          it_behaves_like 'issuable quick actions'
        end
      end

      context 'when note only have commands' do
        it 'adds commands applied message to note errors' do
          note_text = %(/close)
          service = double(:service)
          allow(Issues::UpdateService).to receive(:new).and_return(service)
          expect(service).to receive(:execute)

          note = described_class.new(project, user, opts.merge(note: note_text)).execute

          expect(note.errors[:commands_only]).to be_present
        end
      end
    end

    context 'personal snippet note' do
      subject { described_class.new(nil, user, params).execute }

      let(:snippet) { create(:personal_snippet) }
      let(:params) do
        { note: 'comment', noteable_type: 'Snippet', noteable_id: snippet.id }
      end

      it 'returns a valid note' do
        expect(subject).to be_valid
      end

      it 'returns a persisted note' do
        expect(subject).to be_persisted
      end

      it 'note has valid content' do
        expect(subject.note).to eq(params[:note])
      end
    end

    context 'note with emoji only' do
      it 'creates regular note' do
        opts = {
          note: ':smile: ',
          noteable_type: 'Issue',
          noteable_id: issue.id
        }
        note = described_class.new(project, user, opts).execute

        expect(note).to be_valid
        expect(note.note).to eq(':smile:')
      end
    end

    context 'reply to individual note' do
      let(:existing_note) { create(:note_on_issue, noteable: issue, project: project) }
      let(:reply_opts) { opts.merge(in_reply_to_discussion_id: existing_note.discussion_id) }

      subject { described_class.new(project, user, reply_opts).execute }

      it 'creates a DiscussionNote in reply to existing note' do
        expect(subject).to be_a(DiscussionNote)
        expect(subject.discussion_id).to eq(existing_note.discussion_id)
      end

      it 'converts existing note to DiscussionNote' do
        expect do
          existing_note

          Timecop.freeze(Time.now + 1.minute) { subject }

          existing_note.reload
        end.to change { existing_note.type }.from(nil).to('DiscussionNote')
            .and change { existing_note.updated_at }
      end
    end
  end
end
