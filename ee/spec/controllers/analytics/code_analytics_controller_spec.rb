# frozen_string_literal: true

require 'spec_helper'

describe Analytics::CodeAnalyticsController do
  set(:current_user) { create(:user) }
  set(:group) { create(:group) }
  set(:project) { create(:project, :repository, group: group) }

  before do
    sign_in(current_user)
    allow_any_instance_of(Analytics::CodeAnalyticsFinder).to receive(:execute).and_return(true)
    allow_any_instance_of(Analytics::HotspotsTree).to receive(:build).and_return(true)
    stub_licensed_features(code_analytics: true)
  end

  describe 'GET show' do
    subject { get :show, format: :html, params: {} }

    it 'authorizes visibility of code analytics feature' do
      expect(Ability).to receive(:allowed?).with(current_user, :view_code_analytics, :global).and_return(false)
      subject

      expect(response.code).to eq '403'
    end

    it "returns a 403 if user does not have premium license" do
      stub_licensed_features(code_analytics: false)
      subject

      expect(response.code).to eq '403'
    end
  end

  describe 'GET show.json' do
    subject { get :show, format: :json, params: params }
    let(:params) { { group_id: group.full_path, project_id: project.full_path, timeframe: "last_30_days" } }

    context "when signed in user has at least reporter level access" do
      before do
        group.add_reporter current_user
      end

      it "returns a 404 if group is not found" do
        params['group_id'] = "incorrect/path"
        subject

        expect(response.code).to eq '404'
      end

      it "returns a 404 if project is not found" do
        params['project_id'] = "incorrect/path"
        subject

        expect(response.code).to eq '404'
      end

      context "with invalid timeframe" do
        it "returns 422" do
          params['timeframe'] = "gibberish"
          subject

          expect(response.code).to eq '422'
        end
      end
    end
  end
end
