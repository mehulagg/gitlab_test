# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::BlobController do
  include ProjectForksHelper
  include FakeBlobHelpers

  let(:project) { create(:project, :public, :repository) }

  shared_examples "file matches a codeowners rule" do
    # Expected behavior for both these contexts should be equivalent, however
    #   the feature flag is used in code to control which code path is followed.
    #
    context ":use_legacy_codeowner_validations is true" do
      before do
        stub_feature_flags(use_legacy_codeowner_validations: true)
      end

      it_behaves_like "renders to the expected_view with an error msg"
    end

    context ":use_legacy_codeowner_validations is false" do
      before do
        stub_feature_flags(use_legacy_codeowner_validations: false)
      end

      it_behaves_like "renders to the expected_view with an error msg"
    end
  end

  shared_examples "renders to the expected_view with an error msg" do
    let(:error_msg) do
      "Pushes to protected branches that contain changes to files that match " \
      "patterns defined in `CODEOWNERS` are disabled for this project. " \
      "Please submit these changes via a merge request.  The following " \
      "pattern(s) from `CODEOWNERS` were matched: - docs/ "
    end

    before do
      allow(::ProtectedBranch).to receive(:branch_requires_code_owner_approval?)
        .and_return(true)

      expect_next_instance_of(Repository) do |repo|
        allow(repo).to receive(:code_owners_blob)
          .with(ref: "master")
          .and_return(
            fake_blob(
              path: "CODEOWNERS",
              data: "*.rb @#{user.username}\ndocs/ @#{user.username}"
            )
          )
      end

      stub_licensed_features(code_owner_approval_required: true)
    end

    it "renders to the edit page with an error msg" do
      default_params[:file_path] = "docs/EXAMPLE_FILE"

      subject

      expect(flash[:alert]).to eq(error_msg)
      expect(response).to render_template(expected_view)
    end
  end

  describe 'POST create' do
    let(:user) { create(:user) }
    let(:default_params) do
      {
        namespace_id: project.namespace,
        project_id: project,
        id: 'master',
        branch_name: 'master',
        file_name: 'docs/EXAMPLE_FILE',
        content: 'Added changes',
        commit_message: 'Create CHANGELOG'
      }
    end

    before do
      project.add_developer(user)

      sign_in(user)
    end

    it 'redirects to blob' do
      post :create, params: default_params

      expect(response).to be_redirect
    end

    it_behaves_like "file matches a codeowners rule" do
      subject { post :create, params: default_params }

      let(:expected_view) { :new }
    end
  end

  describe 'PUT update' do
    let(:user) { create(:user) }
    let(:default_params) do
      {
        namespace_id: project.namespace,
        project_id: project,
        id: 'master/CHANGELOG',
        branch_name: 'master',
        content: 'Added changes',
        commit_message: 'Update CHANGELOG'
      }
    end

    before do
      project.add_maintainer(user)

      sign_in(user)
    end

    it_behaves_like "file matches a codeowners rule" do
      subject { put :update, params: default_params }

      let(:expected_view) { :edit }
    end
  end
end
