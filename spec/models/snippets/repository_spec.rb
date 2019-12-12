# frozen_string_literal: true

require 'spec_helper'

describe Snippets::Repository do
  let_it_be(:personal_snippet) { create(:personal_snippet) }
  let_it_be(:project_snippet) { create(:project_snippet) }
  let(:personal_repository) { described_class.new(personal_snippet) }
  let(:project_repository) { described_class.new(project_snippet) }

  it 'configures the snippet repo type' do
    expect(personal_repository.repo_type.name).to eq :snippet
  end

  it 'configures the project gl_repository field' do
    aggregate_failures do
      expect(personal_repository.gl_repository).to eq "snippet-#{personal_snippet.id}"
      expect(project_repository.gl_repository).to eq "snippet-#{project_snippet.id}"
    end
  end

  it 'initializes container as the snippet' do
    expect(personal_repository.container).to eq personal_snippet
  end

  it 'configures the full path depending on the type' do
    aggregate_failures do
      expect(personal_repository.full_path).to eq "snippets/#{personal_snippet.id}"
      expect(project_repository.full_path).to eq "#{project_snippet.project.full_path}/snippets/#{project_snippet.id}"
    end
  end
end
