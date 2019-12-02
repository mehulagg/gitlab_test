# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20191202175443_fix_orphan_epics_events.rb')

describe FixOrphanEpicsEvents, :migration do
  let(:users) { table(:users) }
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:events) { table(:events) }
  let(:epics) { table(:epics) }
  let(:notes) { table(:notes) }
  let(:user) { users.create!(email: 'email@email.com', name: 'foo', username: 'foo', projects_limit: 0) }
  let(:issues) { table(:issues) }
  let(:group_1) { namespaces.create!(name: 'gitlab', path: 'gitlab') }
  let(:group_2) { namespaces.create!(name: 'gitlap', path: 'gitlap') }
  let(:project) { projects.create!(namespace_id: group_1.id) }
  let(:epic_1) { epics.create!(iid: 1, title: 'Epic1', title_html: "Epic1", group_id: group_1.id, author_id: user.id) }
  let(:epic_2) { epics.create!(iid: 2, title: 'Epic2', title_html: "Epic2", group_id: group_2.id, author_id: user.id) }
  let(:issue_1) { issues.create!(description: 'first', state: 'opened', project_id: project.id) }
  let(:epic_1_note) { notes.create!(noteable_type: 'Epic', noteable_id: epic_1.id, note: 'Any') }
  let(:epic_2_note) { notes.create!(noteable_type: 'Epic', noteable_id: epic_2.id, note: 'Other') }
  let(:issue_1_note_1) { notes.create!(noteable_type: 'Issue', noteable_id: issue_1.id, note: 'Any') }
  let(:issue_1_note_2) { notes.create!(noteable_type: 'Issue', noteable_id: issue_1.id, note: 'Any 2') }

  let!(:epic_note_event_1) { events.create!(target_type: "Note", target_id: epic_1_note.id, author_id: user.id, action: 1) }
  let!(:issue_note_event_1) { events.create!(target_type: "Note", target_id: issue_1_note_1.id, author_id: user.id, action: 1) }
  let!(:epic_note_event_2) { events.create!(target_type: "Note", target_id: epic_2_note.id, author_id: user.id, action: 1) }
  let!(:issue_note_event_2) { events.create!(target_type: "Note", target_id: issue_1_note_2.id, author_id: user.id, action: 1) }
  let!(:not_a_note_event) { events.create!(target_type: "User", target_id: user.id, author_id: user.id, action: 1) }

  it 'populates epic notes events with missing group_id' do
    migrate!

    expect(epic_note_event_1.reload.group_id).to eq(group_1.id)
    expect(epic_note_event_2.reload.group_id).to eq(group_2.id)
    expect(issue_note_event_1.reload.group_id).to be_nil
    expect(issue_note_event_2.reload.group_id).to be_nil
    expect(not_a_note_event.reload.group_id).to be_nil
  end
end
