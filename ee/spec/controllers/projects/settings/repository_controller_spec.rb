# frozen_string_literal: true

require 'spec_helper'

describe Projects::Settings::RepositoryController do
  let(:project) { create(:project_empty_repo, :public) }
  let(:user) { create(:user) }

  before do
    project.add_maintainer(user)
    sign_in(user)
  end

  describe 'GET show' do
    context 'push rule' do
      subject(:push_rule) { assigns(:push_rule) }

      it 'is created' do
        get :show, params: { namespace_id: project.namespace, project_id: project }

        is_expected.to be_persisted
      end

      it 'project_push_rule is created' do
        get :show, params: { namespace_id: project.namespace, project_id: project }

        expect(project.project_push_rule).to be_persisted
      end

      it 'if project project_push_rule exists, it is not created' do
        rule = project.create_project_push_rule(push_rule: create(:push_rule))

        get :show, params: { namespace_id: project.namespace, project_id: project }

        expect(project.project_push_rule).to eq(rule)
      end

      context 'unlicensed' do
        before do
          stub_licensed_features(push_rules: false)
        end

        it 'is not created' do
          get :show, params: { namespace_id: project.namespace, project_id: project }

          is_expected.to be_nil
        end
      end
    end
  end
end
