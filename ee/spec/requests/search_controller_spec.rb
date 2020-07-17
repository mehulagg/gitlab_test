# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SearchController, type: :request do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :public, :repository, :wiki_repo, name: 'awesome project', group: group) }

  before_all do
    login_as(user)
  end

  def send_search_request(params)
    get search_path, params: params
  end

  shared_examples 'an efficient database result' do
    it 'avoids N+1 database queries' do
      create_list(object, 5, *creation_traits, creation_args)

      ensure_elasticsearch_index! if elastic_search_enabled

      control = ActiveRecord::QueryRecorder.new(skip_cached: false) { send_search_request(params) }
      create_list(object, 5, *creation_traits, creation_args)

      ensure_elasticsearch_index! if elastic_search_enabled

      expect { send_search_request(path) }.not_to exceed_all_query_limit(control).with_threshold(threshold)
    end
  end

  describe 'GET /search' do
    let(:creation_traits) { [] }
    let(:elastic_search_enabled) { false }

    context 'for issues scope' do
      let(:object) { :issue }
      let(:creation_args) { { project: project } }
      let(:params) { { search: '*', scope: 'issues' } }
      let(:threshold) { 0 }

      context 'when elasticsearch is not enabled' do
        it_behaves_like 'an efficient database result'
      end

      context 'when elasticsearch is enabled', :elastic, :sidekiq_inline do
        before do
          stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
        end
        let(:elastic_search_enabled) { true }

        it_behaves_like 'an efficient database result'
      end
    end

    context 'for merge_request scope' do
      let(:creation_traits) { [:unique_branches] }
      let(:object) { :merge_request }
      let(:creation_args) { { source_project: project } }
      let(:params) { { search: '*', scope: 'merge_requests' } }
      let(:threshold) { 0 }

      context 'when elasticsearch is not enabled' do
        it_behaves_like 'an efficient database result'
      end

      context 'when elasticsearch is enabled', :elastic, :sidekiq_inline do
        before do
          stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
        end
        let(:elastic_search_enabled) { true }

        it_behaves_like 'an efficient database result'
      end
    end

    context 'for project scope' do
      let(:creation_traits) { [:public] }
      let(:object) { :project }
      let(:creation_args) { {} }
      let(:params) { { search: '*', scope: 'projects' } }
      # some N+1 queries still exist
      # each project requires 3 extra queries
      #   - one count for forks
      #   - one count for open MRs
      #   - one count for open Issues
      let(:threshold) { 15 }

      context 'when elasticsearch is not enabled' do
        it_behaves_like 'an efficient database result'
      end

      context 'when elasticsearch is enabled', :elastic, :sidekiq_inline do
        before do
          stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
        end
        let(:elastic_search_enabled) { true }

        it_behaves_like 'an efficient database result'
      end
    end
  end
end
