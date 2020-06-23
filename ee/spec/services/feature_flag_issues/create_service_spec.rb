# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FeatureFlagIssues::CreateService do
  let_it_be(:project) { create(:project) }
  let_it_be(:developer) { create(:user) }

  before_all do
    project.add_developer(developer)
  end

  describe '#execute' do
    it 'creates a system note' do
      feature_flag = create(:operations_feature_flag, project: project)
      issue = create(:issue, project: project)
      create_params = { issuable_references: [issue.to_reference] }

      described_class.new(feature_flag, developer, create_params).execute

      expect(Note.count).to eq(1)
      note = Note.where(noteable_id: issue.id, noteable_type: 'Issue').last
      expect(note.note).to eq("marked this issue as related to #{feature_flag.to_reference(project)}")
      expect(note.author).to eq(developer)
      expect(note.project).to eq(project)
      expect(note.noteable_type).to eq('Issue')
      expect(note.system_note_metadata.action).to eq('relate')
      expect(note.note_html).to include("href=\"/#{project.full_path}/-/feature_flags/#{feature_flag.iid}\"")
    end
  end
end
