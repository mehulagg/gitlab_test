# frozen_string_literal: true

require 'spec_helper'

describe Admin::PushRulesController do
  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
  end

  describe '#update' do
    let(:params) do
      {
        deny_delete_tag: "true", delete_branch_regex: "any", commit_message_regex: "any", branch_name_regex: "any",
        force_push_regex: "any", author_email_regex: "any", member_check: "true", file_name_regex: "any",
        max_file_size: "0", prevent_secrets: "true", target_type: ::PushRule::RULES_TYPES[:instance]
      }
    end

    it 'updates sample push rule' do
      expect_next_instance_of(PushRule) do |instance|
        expect(instance).to receive(:update).with(ActionController::Parameters.new(params).permit!)
      end

      patch :update, params: { push_rule: params }

      expect(response).to redirect_to(admin_push_rule_path)
    end

    it 'updates sample push rule target type' do
      create(:push_rule_sample, target_type: nil)

      patch :update, params: { push_rule: params }

      expect(PushRule.global.instance?).to eq(true)
    end

    context 'push rules unlicensed' do
      before do
        stub_licensed_features(push_rules: false)
      end

      it 'returns 404' do
        patch :update, params: { push_rule: params }

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe '#show' do
    it 'returns 200' do
      get :show

      expect(response).to have_gitlab_http_status(:ok)
    end

    context 'push rules unlicensed' do
      before do
        stub_licensed_features(push_rules: false)
      end

      it 'returns 404' do
        get :show

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
