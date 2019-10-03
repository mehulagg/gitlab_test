# frozen_string_literal: true

require 'spec_helper'

describe ElasticIndexerWorker, :elastic do
  subject { described_class.new }

  before do
    stub_ee_application_setting(elasticsearch_indexing: true)
  end

  def search(body = {})
    current_es_index.client.search(index: current_es_index.name, body: body)
  end

  it 'returns true if ES disabled' do
    stub_ee_application_setting(elasticsearch_indexing: false)

    expect(Elastic::IndexRecordService).not_to receive(:new)

    expect(subject.perform("index", "Milestone", 1, 1)).to be_truthy
  end

  describe 'Indexing, updating, and deleting records' do
    using RSpec::Parameterized::TableSyntax

    where(:type, :name, :attribute) do
      :project       | "Project"      | :name
      :issue         | "Issue"        | :title
      :note          | "Note"         | :note
      :milestone     | "Milestone"    | :title
      :merge_request | "MergeRequest" | :title
    end

    with_them do
      it 'calls record indexing' do
        object = create(type)

        expect_next_instance_of(Elastic::IndexRecordService) do |service|
          expect(service).to receive(:execute).with(object, true, {}).and_return(true)
        end

        subject.perform("index", name, object.id, object.es_id)
      end

      it 'deletes from index when an object is deleted' do
        object = nil

        Sidekiq::Testing.disable! do
          object = create(type)
          subject.perform("index", name, object.id, object.es_id)
          Gitlab::Elastic::Helper.refresh_index
          object.destroy
        end

        expect do
          subject.perform("delete", name, object.id, object.es_id, { 'es_parent' => object.es_parent })
          Gitlab::Elastic::Helper.refresh_index
        end.to change { search['hits']['total'] }.by(-1)
      end
    end
  end

  it 'deletes a project with all nested objects' do
    project, issue, milestone, note, merge_request = nil

    Sidekiq::Testing.disable! do
      project = create :project, :repository
      subject.perform("index", "Project", project.id, project.es_id)

      issue = create :issue, project: project
      subject.perform("index", "Issue", issue.id, issue.es_id)

      milestone = create :milestone, project: project
      subject.perform("index", "Milestone", milestone.id, milestone.es_id)

      note = create :note, project: project
      subject.perform("index", "Note", note.id, note.es_id)

      merge_request = create :merge_request, target_project: project, source_project: project
      subject.perform("index", "MergeRequest", merge_request.id, merge_request.es_id)
    end

    ElasticCommitIndexerWorker.new.perform(project.id)
    Gitlab::Elastic::Helper.refresh_index

    ## All database objects + data from repository. The absolute value does not matter
    expect(search['hits']['total']).to be > 40

    subject.perform("delete", "Project", project.id, project.es_id)
    Gitlab::Elastic::Helper.refresh_index

    expect(search['hits']['total']).to be(0)
  end

  it 'retries if index raises error' do
    object = create(:project)

    expect_next_instance_of(Elastic::IndexRecordService) do |service|
      allow(service).to receive(:execute).and_raise(Elastic::IndexRecordService::ImportError)
    end

    expect do
      subject.perform("index", 'Project', object.id, object.es_id)
    end.to raise_error(Elastic::IndexRecordService::ImportError)
  end

  it 'ignores Elasticsearch::Transport::Transport::Errors::NotFound error' do
    object = create(:project)

    expect_next_instance_of(Elastic::IndexRecordService) do |service|
      allow(service).to receive(:execute).and_raise(Elasticsearch::Transport::Transport::Errors::NotFound)
    end

    expect(subject.perform("index", 'Project', object.id, object.es_id)).to eq(true)
  end

  it 'ignores missing records' do
    expect(subject.perform("index", 'Project', -1, 'project_-1')).to eq(true)
  end
end
