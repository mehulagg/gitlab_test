# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::GitAccessSnippet do
  let_it_be(:actor) { create(:user) }
  let_it_be(:project) { create(:project, :public) }
  let_it_be(:snippet) { create(:project_snippet, :public, :repository, project: project) }

  let(:pull_access_check) { access.check('git-upload-pack', Gitlab::GitAccess::ANY) }

  subject(:access) { Gitlab::GitAccessProjectSnippet.new(actor, snippet, 'ssh', authentication_abilities: [:download_code]) }

  describe 'when feature flag :version_snippets is disabled' do
    before do
      stub_feature_flags(version_snippets: false)
    end

    it 'does not allow push and pull access' do
      expect { pull_access_check }.to raise_project_not_found
    end
  end

  describe '#check_snippet_accessibility!' do
    context 'when the snippet exists' do
      it 'allows access' do
        project.add_developer(actor)

        expect { pull_access_check }.not_to raise_error
      end
    end

    context 'when the snippet is nil' do
      let(:snippet) { nil }

      it 'blocks access with "not found"' do
        expect { pull_access_check }.to raise_snippet_not_found
      end
    end

    context 'when the snippet does not have a repository' do
      let(:snippet) { build_stubbed(:personal_snippet) }

      it 'blocks access with "not found"' do
        expect { pull_access_check }.to raise_snippet_not_found
      end
    end
  end

  private

  def raise_snippet_not_found
    raise_error(Gitlab::GitAccess::NotFoundError, Gitlab::GitAccess::ERROR_MESSAGES[:snippet_not_found])
  end

  def raise_project_not_found
    raise_error(Gitlab::GitAccess::NotFoundError, Gitlab::GitAccess::ERROR_MESSAGES[:project_not_found])
  end
end
