# frozen_string_literal: true

require 'spec_helper'

describe FeatureFlagEntity do
  let(:feature_flag) { create(:operations_feature_flag, project: project) }
  let(:project) { create(:project) }
  let(:request) { double('request', current_user: user) }
  let(:user) { create(:user) }
  let(:entity) { described_class.new(feature_flag, request: request) }

  before do
    project.add_developer(user)

    stub_licensed_features(feature_flags: true)
  end

  subject { entity.as_json }

  it 'has feature flag attributes' do
    expect(subject).to include(:id, :active, :created_at, :updated_at,
      :description, :name, :edit_path, :destroy_path)
  end

  it 'allows user to update unprotected * scope' do
    scope = subject[:scopes].first
    expect(scope[:protected]).to eq(false)
    expect(scope[:can_update]).to eq(true)
  end

  context 'when feature flag has scopes' do
    before do
      stub_licensed_features(protected_environments: true)
      feature_flag.scopes.create!(environment_scope: 'production', active: true)
      feature_flag.scopes.create!(environment_scope: 'staging', active: true)
    end

    let(:production_scope) do
      subject[:scopes].find do |scope|
        scope[:environment_scope] == 'production'
      end
    end

    let(:staging_scope) do
      subject[:scopes].find do |scope|
        scope[:environment_scope] == 'staging'
      end
    end

    context 'when user does not have permission to deploy protected environment' do
      before do
        create(:protected_environment, project: project, name: 'production')
      end

      it 'does not user to update protected scope' do
        expect(production_scope[:can_update]).to eq(false)
        expect(production_scope[:protected]).to eq(true)
      end

      it 'allows user to update unprotected scope' do
        expect(staging_scope[:can_update]).to eq(true)
        expect(staging_scope[:protected]).to eq(false)
      end
    end

    context 'when user has permission to deploy environment' do
      before do
        create(:protected_environment, project: project, name: 'production', authorize_user_to_deploy: user)
      end

      it 'allows user to update protected scope' do
        expect(production_scope[:can_update]).to eq(true)
        expect(production_scope[:protected]).to eq(true)
      end
    end
  end
end
