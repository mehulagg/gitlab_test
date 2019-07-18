# frozen_string_literal: true

require 'rails_helper'

describe Gitlab::BackgroundMigration::MigratePromotedEpicsDiscussionIds, :migration, schema: 20190715193142 do
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:users) { table(:users) }
  let(:issues) { table(:issues) }
  let(:epics) { table(:epics) }
  let(:notes) { table(:notes) }

  let(:user) { users.create!(email: 'test@example.com', projects_limit: 100, username: 'test') }
  let(:namespace) { namespaces.create(name: 'gitlab', path: 'gitlab-org') }
  let(:project) { projects.create(namespace_id: namespace.id, name: 'foo') }
  let(:issue) { issues.create(project_id: project.id, title: 'Issue with discussion') }
  let!(:issue_note) { notes.create(project_id: project.id, note: 'note comment', noteable_id: issue.id, noteable_type: 'Issue', discussion_id: 'd1') }
  let(:epic1) { epics.create(id: 1, author_id: user.id, iid: 1, group_id: namespace.id, title: 'Epic with discussion', title_html: 'Epic with discussion') }
  let!(:epic1_note1) { notes.create(note: 'note comment', noteable_id: epic1.id, noteable_type: 'Epic', discussion_id: 'd1') }
  let!(:epic1_note2) { notes.create(system: true, note: 'promoted from issue XXX', noteable_id: epic1.id, noteable_type: 'Epic', discussion_id: 'system1') }

  describe '#perform with batch of discussion ids' do
    let(:epic2) { epics.create(id: 2, author_id: user.id, iid: 2, group_id: namespace.id, title: 'Epic with discussion', title_html: 'Epic with discussion') }
    let!(:epic2_note1) { notes.create(note: 'note comment', noteable_id: epic2.id, noteable_type: 'Epic', discussion_id: 'd2') }
    let!(:epic2_note2) { notes.create(system: true, note: 'promoted from issue YYY', noteable_id: epic2.id, noteable_type: 'Epic', discussion_id: 'system2') }

    it 'executes perform and changes discussion ids on all promoted epic discussions' do
      expect(notes.where(discussion_id: 'd1').count).to eq(2)

      subject.perform(%w(d1 system1 d2 system2))

      expect(notes.where(discussion_id: 'd1').count).to eq(1)
      expect(notes.where(discussion_id: 'd1').first.noteable_type).to eq('Issue')
      expect(epic1_note1.reload.discussion_id).not_to eq('d1')
      expect(epic1_note2.reload.discussion_id).not_to eq('system1')
      expect(epic2_note1.reload.discussion_id).not_to eq('d2')
      expect(epic2_note2.reload.discussion_id).not_to eq('system2')
    end
  end
end
