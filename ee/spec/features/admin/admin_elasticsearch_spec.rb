# frozen_string_literal: true

require 'spec_helper'

describe 'Admin manages Elasticsearch' do
  before do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    stub_licensed_features(elastic_search: true)

    sign_in create(:admin)
  end

  context 'global settings', :elastic_stub do
    def current_settings
      ApplicationSetting.current_without_cache
    end

    before do
      current_settings.update!(elasticsearch_read_index: current_es_index)

      visit admin_elasticsearch_settings_path
    end

    it 'changes Elasticsearch settings' do
      page.within('#content-body.content') do
        check 'Advanced Global Search enabled'

        click_button 'Save changes'
      end

      aggregate_failures do
        expect(current_settings.elasticsearch_search).to be_truthy
        expect(page).to have_content 'Application settings saved successfully'
      end
    end

    it 'allows limiting projects and namespaces to index', :js do
      project = create(:project)
      namespace = create(:namespace)

      page.within('#content-body.content') do
        expect(page).not_to have_content('Namespaces to index')
        expect(page).not_to have_content('Projects to index')

        check 'Limit namespaces and projects that can be indexed'

        expect(page).to have_content('Namespaces to index')
        expect(page).to have_content('Projects to index')

        fill_in 'Namespaces to index', with: namespace.name
        wait_for_requests
      end

      page.within('#select2-drop') do
        expect(page).to have_content(namespace.full_path)
      end

      page.within('#content-body.content') do
        find('.js-limit-namespaces .select2-choices input[type=text]').native.send_keys(:enter)

        fill_in 'Projects to index', with: project.name
        wait_for_requests
      end

      page.within('#select2-drop') do
        expect(page).to have_content(project.full_name)
      end

      page.within('#content-body.content') do
        find('.js-limit-projects .select2-choices input[type=text]').native.send_keys(:enter)

        click_button 'Save changes'
      end

      wait_for_all_requests

      expect(current_settings.elasticsearch_limit_indexing).to be_truthy
      expect(ElasticsearchIndexedNamespace.exists?(namespace_id: namespace.id)).to be_truthy
      expect(ElasticsearchIndexedProject.exists?(project_id: project.id)).to be_truthy
      expect(page).to have_content 'Application settings saved successfully'
    end

    it 'allows removing all namespaces and projects', :js do
      stub_ee_application_setting(elasticsearch_limit_indexing: true)

      namespace = create(:elasticsearch_indexed_namespace).namespace
      project = create(:elasticsearch_indexed_project).project

      visit admin_elasticsearch_settings_path

      expect(ElasticsearchIndexedNamespace.count).to be > 0
      expect(ElasticsearchIndexedProject.count).to be > 0

      page.within('#content-body.content') do
        expect(page).to have_content('Namespaces to index')
        expect(page).to have_content('Projects to index')
        expect(page).to have_content(namespace.full_name)
        expect(page).to have_content(project.full_name)

        find('.js-limit-namespaces .select2-search-choice-close').click
        find('.js-limit-projects .select2-search-choice-close').click

        expect(page).not_to have_content(namespace.full_name)
        expect(page).not_to have_content(project.full_name)

        click_button 'Save changes'
      end

      expect(ElasticsearchIndexedNamespace.count).to eq(0)
      expect(ElasticsearchIndexedProject.count).to eq(0)
      expect(page).to have_content 'Application settings saved successfully'
    end
  end

  context 'manage indices', :js, :sidekiq_inline do
    let(:elastic_url) { ENV['ELASTIC_URL'] || 'http://localhost:9200' }

    after do
      client = Gitlab::Elastic::Client.build(urls: elastic_url)
      indices = client.indices.get_aliases.keys.grep(/^gitlab-test-/)

      indices.each do |index|
        client.indices.delete(index: index)
      end
    end

    it 'setup and use multiple Elasticsearch indices' do
      create(:project, title: 'test project')

      visit admin_elasticsearch_path

      expect(page).to have_content('Get started with Elasticsearch in GitLab')
      expect(page).to have_link('Learn more')

      # Create first index
      click_on 'Create GitLab index'
      fill_in 'Name', with: 'First index'
      fill_in 'URLs', with: elastic_url
      click_on 'Create GitLab index'

      expect(page).to have_content('First index')
      expect(page).to have_content(%r{#{elastic_url}/gitlab-test-v12p1-\h{8}})

      # Enable first index
      click_on 'Use as search source'

      expect(page).to have_content('Are you sure you want to switch to First index?')

      page.within('.modal') do
        click_on 'Switch'
      end

      expect(page).to have_content('First index Search source')

      # Enable indexing
      click_on 'Resume indexing'
      page.within '.modal' do
        click_on 'Resume indexing'
      end
      wait_for_requests

      # Index data on first index
      click_on 'Reindex'
      page.within '.modal' do
        click_on 'Reindex'
      end
      wait_for_requests

      # Enable searching through ES
      visit admin_elasticsearch_settings_path
      check 'Advanced Global Search enabled'
      click_button 'Save changes'

      expect(page).to have_content 'Application settings saved successfully'

      # Search on first index
      visit search_path
      submit_search 'test'
      wait_for_requests

      expect(page).to have_content('Advanced search functionality is enabled.')
      expect(page).to have_content('test project')

      # Create second index
      visit admin_elasticsearch_path
      click_on 'Add GitLab index'
      fill_in 'Name', with: 'Second index'
      fill_in 'URLs', with: elastic_url
      click_on 'Create GitLab index'

      # Enable second index
      click_on 'Use as search source'

      expect(page).to have_content('Are you sure you want to switch to Second index?')

      page.within('.modal') do
        click_on 'Switch'
      end

      expect(page).to have_content('Second index Search source')

      # Search on second index, which doesn't have data yet
      visit search_path
      submit_search 'test'
      wait_for_requests

      expect(page).to have_content("We couldn't find any projects matching test")

      # Index second index
      visit admin_elasticsearch_path
      click_on 'Reindex'
      page.within '.modal' do
        click_on 'Reindex'
      end
      wait_for_requests

      # Search again on second index
      visit search_path
      submit_search 'test'
      wait_for_requests

      expect(page).to have_content('test project')
    end

    context 'with an existing Elasticsearch index' do
      before do
        index = create(:elasticsearch_index, friendly_name: 'First index')
        Gitlab::Elastic::Helper.create_empty_index(index)
      end

      it 'edit an Elasticsearch index' do
        visit admin_elasticsearch_path

        expect(page).to have_content('First index')

        click_on 'Edit'
        fill_in 'Name', with: 'Renamed index'
        click_on 'Save changes'

        expect(page).to have_content('Renamed index')
      end

      it 'delete an Elasticsearch index' do
        visit admin_elasticsearch_path
        click_on 'Remove'

        page.within('.modal') do
          find('input').fill_in with: 'First index'
          click_on 'Remove'
        end

        expect(page).not_to have_content('First index')
        expect(page).to have_content('Get started with Elasticsearch in GitLab')
      end
    end
  end
end
