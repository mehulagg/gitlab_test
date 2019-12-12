# frozen_string_literal: true
require 'spec_helper'

describe Gitlab::GlRepository::RepoType do
  let_it_be(:project) { create(:project) }
  let_it_be(:personal_snippet) { create(:personal_snippet, author: project.owner) }
  let_it_be(:project_snippet) { create(:project_snippet, project: project, author: project.owner) }
  let(:container) { project }

  describe Gitlab::GlRepository::PROJECT do
    it_behaves_like 'a repo type' do
      let(:expected_identifier) { "project-#{project.id}" }
      let(:expected_id) { project.id.to_s }
      let(:expected_suffix) { '' }
      let(:expected_repository) { project.repository }
    end

    it 'knows its type' do
      expect(described_class).to be_project
      expect(described_class).not_to be_wiki
      expect(described_class).not_to be_snippet
    end

    it 'detects if valid repository path' do
      expect(described_class.valid?(project.repository.full_path)).to be_truthy
      expect(described_class.valid?(project.wiki.repository.full_path)).to be_truthy
      expect(described_class.valid?(personal_snippet.repository.full_path)).to be_truthy
      expect(described_class.valid?(project_snippet.repository.full_path)).to be_truthy
    end
  end

  describe Gitlab::GlRepository::WIKI do
    it_behaves_like 'a repo type' do
      let(:expected_identifier) { "wiki-#{project.id}" }
      let(:expected_id) { project.id.to_s }
      let(:expected_suffix) { '.wiki' }
      let(:expected_repository) { project.wiki.repository }
    end

    it 'knows its type' do
      expect(described_class).to be_wiki
      expect(described_class).not_to be_project
      expect(described_class).not_to be_snippet
    end

    it 'detects if valid repository path' do
      expect(described_class.valid?(project.repository.full_path)).to be_falsey
      expect(described_class.valid?(project.wiki.repository.full_path)).to be_truthy
      expect(described_class.valid?(personal_snippet.repository.full_path)).to be_falsey
      expect(described_class.valid?(project_snippet.repository.full_path)).to be_falsey
    end
  end

  describe Gitlab::GlRepository::SNIPPET do
    context 'when PersonalSnippet' do
      let(:container) { personal_snippet }

      it_behaves_like 'a repo type' do
        let(:expected_identifier) { "snippet-#{personal_snippet.id}" }
        let(:expected_id) { personal_snippet.id.to_s }
        let(:expected_suffix) { '' }
        let(:expected_repository) { personal_snippet.repository }
      end

      it 'knows its type' do
        expect(described_class).to be_snippet
        expect(described_class).not_to be_wiki
        expect(described_class).not_to be_project
      end

      it 'detects if valid repository path' do
        expect(described_class.valid?(project.repository.full_path)).to be_falsey
        expect(described_class.valid?(project.wiki.repository.full_path)).to be_falsey
        expect(described_class.valid?(personal_snippet.repository.full_path)).to be_truthy
        expect(described_class.valid?(project_snippet.repository.full_path)).to be_truthy
      end
    end

    context 'when ProjectSnippet' do
      let(:container) { project_snippet }

      it_behaves_like 'a repo type' do
        let(:expected_identifier) { "snippet-#{project_snippet.id}" }
        let(:expected_id) { project_snippet.id.to_s }
        let(:expected_suffix) { '' }
        let(:expected_repository) { project_snippet.repository }
      end

      it 'knows its type' do
        expect(described_class).to be_snippet
        expect(described_class).not_to be_wiki
        expect(described_class).not_to be_project
      end

      it 'detects if valid repository path' do
        expect(described_class.valid?(project.repository.full_path)).to be_falsey
        expect(described_class.valid?(project.wiki.repository.full_path)).to be_falsey
        expect(described_class.valid?(personal_snippet.repository.full_path)).to be_truthy
        expect(described_class.valid?(project_snippet.repository.full_path)).to be_truthy
      end
    end
  end
end
