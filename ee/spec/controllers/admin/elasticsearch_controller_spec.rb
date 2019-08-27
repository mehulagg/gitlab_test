# frozen_string_literal: true

require 'spec_helper'

describe Admin::ElasticsearchController do
  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
  end

  describe 'GET #show' do
    it 'renders the show template' do
      get :show

      expect(response).to have_gitlab_http_status(200)
      expect(response).to render_template(:show)
      expect(assigns(:application_setting)).to be_nil
    end
  end

  describe 'GET #settings' do
    before do
      ApplicationSetting.create_from_defaults
    end

    it 'renders the settings template' do
      get :settings

      expect(response).to have_gitlab_http_status(200)
      expect(response).to render_template(:settings)
      expect(assigns(:application_setting)).to be_an_instance_of(ApplicationSetting)
    end
  end

  describe 'PATCH #settings' do
    before do
      ApplicationSetting.create_from_defaults
    end

    it 'updates the settings' do
      expect(ApplicationSetting.current.elasticsearch_limit_indexing).to eq(false)

      patch :settings, params: { application_setting: { elasticsearch_limit_indexing: true } }

      expect(response).to redirect_to(admin_elasticsearch_settings_path)
      expect(ApplicationSetting.current.elasticsearch_limit_indexing).to eq(true)
    end

    it 'renders validation errors' do
      patch :settings, params: { application_setting: { elasticsearch_search: true } }

      expect(response).to have_gitlab_http_status(200)
      expect(response).to render_template(:settings)
      expect(assigns(:application_setting).errors).to include(:elasticsearch_read_index)

      expect(ApplicationSetting.current.elasticsearch_search).to eq(false)
    end
  end
end
