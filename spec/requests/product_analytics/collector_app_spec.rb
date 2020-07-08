# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ProductAnalytics::CollectorApp' do
  let_it_be(:project) { create(:project) }
  let(:params) { {} }

  subject { get '/-/collector/i', params: params }

  context 'correct event params' do
    let(:params) do
      {
        aid: project.id,
        p: 'web',
        tna: 'sp',
        tv: 'js-2.14.0',
        eid: SecureRandom.uuid,
        duid: SecureRandom.uuid,
        sid: SecureRandom.uuid,
        vid: 4,
        url: 'http://example.com/products/1',
        refr: 'http://example.com/products/1',
        lang: 'en-US',
        cookie: true,
        tz: 'America/Los_Angeles',
        cs: 'UTF-8'
      }
    end

    it 'repond with 200' do
      expect { subject }.to change { ProductAnalyticsEvent.count }.by(1)

      expect(response).to have_gitlab_http_status(:ok)
    end
  end

  context 'empty event params' do
    it 'responds with 404' do
      expect { subject }.not_to change { ProductAnalyticsEvent.count }

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end
end
