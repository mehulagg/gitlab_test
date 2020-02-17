# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::GitAccessProjectSnippet do
  include TermsHelper
  include GitHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :public) }
  let_it_be(:snippet) { create(:project_snippet, :private, :repository, project: project, author: user) }

  let(:actor) { user }
  let(:protocol) { 'ssh' }
  let(:changes) { Gitlab::GitAccess::ANY }
  let(:authentication_abilities) { [:download_code, :push_code] }
  let(:push_access_check) { access.check('git-receive-pack', changes) }
  let(:pull_access_check) { access.check('git-upload-pack', changes) }

  describe '#check', :aggregate_failures do
    include ProjectHelpers

    let(:snippet) { create(:project_snippet, :private, :repository, project: project) }
    let(:user) { membership == :author ? snippet.author : create_user_from_membership(project, membership) }

    shared_examples_for 'checks accessibility' do
      [:anonymous, :non_member, :guest, :reporter, :maintainer, :admin, :author].each do |membership|
        context membership.to_s do
          let(:membership) { membership }

          it 'respects accessibility' do
            if Ability.allowed?(user, :update_snippet, snippet)
              expect { push_access_check }.not_to raise_error
            else
              expect { push_access_check }.to raise_error(described_class::UnauthorizedError)
            end

            if Ability.allowed?(user, :read_snippet, snippet)
              expect { pull_access_check }.not_to raise_error
            else
              expect { pull_access_check }.to raise_error(described_class::UnauthorizedError)
            end
          end
        end
      end
    end

    context 'when project is public' do
      it_behaves_like 'checks accessibility'
    end

    context 'when project is public but snippet feature is private' do
      let(:project) { create(:project, :public) }

      before do
        update_feature_access_level(project, :private)
      end

      it_behaves_like 'checks accessibility'
    end

    context 'when project is not accessible' do
      let(:project) { create(:project, :private) }

      [:anonymous, :non_member].each do |membership|
        context membership.to_s do
          let(:membership) { membership }

          it 'respects accessibility' do
            expect { push_access_check }.to raise_error(described_class::NotFoundError)
            expect { pull_access_check }.to raise_error(described_class::NotFoundError)
          end
        end
      end
    end
  end

  context 'terms are enforced', :aggregate_failures do
    before do
      enforce_terms
    end

    it 'blocks access when the user did not accept terms' do
      message = /must accept the Terms of Service in order to perform this action/

      expect { push_access_check }.to raise_unauthorized(message)
      expect { pull_access_check }.to raise_unauthorized(message)
    end

    it 'allows access when the user accepted the terms' do
      accept_terms(user)

      expect { push_access_check }.not_to raise_error
      expect { pull_access_check }.not_to raise_error
    end
  end

  private

  def access
    described_class.new(
      actor,
      snippet,
      protocol,
      authentication_abilities: authentication_abilities,
      auth_result_type: nil
    )
  end

  def raise_unauthorized(message)
    raise_error(Gitlab::GitAccess::UnauthorizedError, message)
  end
end
