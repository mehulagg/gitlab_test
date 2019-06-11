# frozen_string_literal: true

shared_examples 'issuable quick actions' do |issuable_type|
  QuickAction = Struct.new(:action_text, :expectation) do
    def skip_access_check
      action_text["/todo"] ||
        action_text["/done"] ||
        action_text["/subscribe"] ||
        action_text["/shrug"] ||
        action_text["/tableflip"]
    end
  end

  # Quick actions shared by issues and merge requests
  let(:issuable_quick_actions) do
    [
      QuickAction.new("/subscribe", ->(noteable, can_use_quick_action) {
        expect(noteable.subscribed?(note_author, issuable.project)).to eq(can_use_quick_action)
      }),
      QuickAction.new("/unsubscribe", ->(noteable, can_use_quick_action) {
        expect(noteable.subscribed?(note_author, issuable.project)).to eq(false)
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
        expect(noteable.opened?).to eq(true)

        unless can_use_quick_action
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

  let(:old_assignee) { create(:user) }

  before do
    project.add_developer(old_assignee)
    issuable.update(assignees: [old_assignee])
  end

  context 'when user can update issuable' do
    set(:developer) { create(:user) }
    let(:note_author) { developer }

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
    let(:note_author) { non_member }

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
