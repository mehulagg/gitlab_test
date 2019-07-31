# frozen_string_literal: true

require 'rails_helper'

describe Gitlab::BackgroundMigration::FixPromotedEpicsDiscussionIds, :migration, schema: 20190715193142 do
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:users) { table(:users) }
  let(:issues) { table(:issues) }
  let(:epics) { table(:epics) }
  let(:notes) { table(:notes) }

  let(:user) { users.create!(email: 'test@example.com', projects_limit: 100, username: 'test') }
  let(:namespace) { namespaces.create(name: 'gitlab', path: 'gitlab-org') }
  let(:project) { projects.create(namespace_id: namespace.id, name: 'foo') }
  let(:epic) { epics.create(id: 1, author_id: user.id, iid: 1, group_id: namespace.id, title: 'Epic with discussion', title_html: 'Epic with discussion') }

  describe '#perform with batch of discussion ids' do
    context 'with multiple promoted epics' do
      let(:epic2) { epics.create(id: 3, author_id: user.id, iid: 1, group_id: namespace.id, title: 'Epic with discussion', title_html: 'Epic with discussion') }
      let!(:note) { notes.create(system: true, note: 'promoted from issue 1', noteable_id: epic.id, noteable_type: 'Epic', discussion_id: 'system1') }
      let!(:note2) { notes.create(system: true, note: 'promoted from issue 1', noteable_id: epic2.id, noteable_type: 'Epic', discussion_id: 'system2') }

      it 'updates notes for promoted epics' do
        subject.perform(1, 100)

        expect(note.reload.discussion_id).not_to eq('system1')
        expect(note2.reload.discussion_id).not_to eq('system2')
      end

      it 'updates notes only for epics in the given interval' do
        subject.perform(1, 2)

        expect(note.reload.discussion_id).not_to eq('system1')
        expect(note2.reload.discussion_id).to eq('system2')
      end
    end

    it 'ignores epics which are not promoted' do
      note = notes.create(system: true, note: 'not promoted', noteable_id: epic.id, noteable_type: 'Epic', discussion_id: 'system1')

      subject.perform(1, 2)

      expect(note.reload.discussion_id).to eq('system1')
    end

    it 'ignores not-epic notes' do
      issue = issues.create(id: 1, project_id: project.id, title: 'Issue with discussion')
      note = notes.create(project_id: project.id, note: 'note comment', noteable_id: issue.id, noteable_type: 'Issue', discussion_id: 'd1')

      subject.perform(1, 2)

      expect(note.reload.discussion_id).to eq('d1')
    end

    it 'sets the same new discussion id for all notes with the same old discussion id' do
      note1 = notes.create(system: true, note: 'promoted from issue 1', noteable_id: epic.id, noteable_type: 'Epic', discussion_id: 'system1')
      note2 = notes.create(system: true, note: 'some comment', noteable_id: epic.id, noteable_type: 'Epic', discussion_id: 'system1')

      subject.perform(1, 2)

      expect(note1.reload.discussion_id).to eq(note2.reload.discussion_id)
      expect(notes.where(discussion_id: note1.discussion_id).count).to eq(2)
      expect(notes.where(discussion_id: 'system1').count).to eq(0)
    end

    it 'sets unique discussion ids for different discussion ids' do
      note1 = notes.create(system: true, note: 'promoted from issue 1', noteable_id: epic.id, noteable_type: 'Epic', discussion_id: 'system1')
      note2 = notes.create(system: true, note: 'some comment', noteable_id: epic.id, noteable_type: 'Epic', discussion_id: 'system2')

      subject.perform(1, 2)

      expect(note1.reload.discussion_id).not_to eq(note2.reload.discussion_id)
    end
  end
end
