# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::GitAccessPersonalSnippet do
  include GitHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:snippet) { create(:personal_snippet, :private, :repository, author: user) }

  let(:actor) { user }
  let(:protocol) { 'ssh' }
  let(:changes) { Gitlab::GitAccess::ANY }
  let(:authentication_abilities) { [:download_code, :push_code] }
  let(:push_access_check) { access.check('git-receive-pack', changes) }
  let(:pull_access_check) { access.check('git-upload-pack', changes) }

  context '#check', :aggregate_failures do
    using RSpec::Parameterized::TableSyntax
    include_context 'ProjectPolicyTable context'
    include ProjectHelpers

    let_it_be(:group) { create(:group) }
    let!(:snippet) { create(:personal_snippet, snippet_level, :repository) }
    let(:user) { membership == :author ? snippet.author : create_user_from_membership(nil, membership) }

    where(:snippet_level, :membership, :_expected_count) do
      permission_table_for_personal_snippet_access
    end

    with_them do
      it "respects accessibility" do
        error_class = described_class::UnauthorizedError

        if Ability.allowed?(user, :update_snippet, snippet)
          expect { push_access_check }.not_to raise_error
        else
          expect { push_access_check }.to raise_error(error_class)
        end

        if Ability.allowed?(user, :read_snippet, snippet)
          expect { pull_access_check }.not_to raise_error
        else
          expect { pull_access_check }.to raise_error(error_class)
        end
      end
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
end
