# frozen_string_literal: true

RSpec.shared_examples 'EE saves project tree successfully' do |ndjson_enabled|
  include ::ImportExport::CommonUtil

  let(:full_path) do
    project_tree_saver.save

    if ndjson_enabled == true
      File.join(shared.export_path, 'tree')
    else
      File.join(shared.export_path, Gitlab::ImportExport.project_filename)
    end
  end

  before do
    stub_feature_flags(ndjson_import_export: ndjson_enabled)
  end

  it 'saves successfully' do
    expect(project_tree_saver.save).to be true
  end

  describe 'the designs json' do
    let(:issue_json) { saved_relations(full_path, :issues, ndjson_enabled).first }

    it 'saves issue.designs correctly' do
      expect(issue_json['designs'].size).to eq(1)
    end

    it 'saves issue.design_versions correctly' do
      actions = issue_json['design_versions'].map do |v|
        v['actions']
      end.flatten

      expect(issue_json['design_versions'].size).to eq(2)
      issue_json['design_versions'].each do |version|
        expect(version['author_id']).to eq(issue.author_id)
      end
      expect(actions.size).to eq(2)
      actions.each do |action|
        expect(action['design']).to be_present
      end
    end
  end

  context 'epics' do
    it 'has epic_issue' do
      expect(saved_relations(full_path, :issues, ndjson_enabled).first['epic_issue']).not_to be_empty
      expect(saved_relations(full_path, :issues, ndjson_enabled).first['epic_issue']['id']).to eql(epic_issue.id)
    end

    it 'has epic' do
      expect(saved_relations(full_path, :issues, ndjson_enabled).first['epic_issue']['epic']['title']).to eql(epic.title)
    end

    it 'does not have epic_id' do
      expect(saved_relations(full_path, :issues, ndjson_enabled).first['epic_issue']['epic_id']).to be_nil
    end

    it 'does not have issue_id' do
      expect(saved_relations(full_path, :issues, ndjson_enabled).first['epic_issue']['issue_id']).to be_nil
    end
  end

  def saved_relations(path, key, ndjson_enabled)
    if ndjson_enabled == true
      json = ndjson_relations(path, key)
      json = json.first if %i(project project_feature).include?(key)
    else
      json = project_json(path)
      json = json[key.to_s] unless key == :project
    end

    json
  end
end
