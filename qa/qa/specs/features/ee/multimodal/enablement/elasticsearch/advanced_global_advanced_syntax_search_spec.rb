# frozen_string_literal: true

require 'securerandom'

module QA
  context 'Enablement:Search' do
    include Support::Api
    describe 'Elasticsearch advanced global search with advanced syntax', :orchestrated, :elasticsearch, :requires_admin, quarantine: { type: :new } do
      let(:project_name_suffix) { SecureRandom.hex(8) }

      let(:api_client) { Runtime::API::Client.new(:gitlab) }

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = "es-adv-global-search-#{project_name_suffix}"
          project.description = "This is a unique project description #{project_name_suffix}"
        end
      end

      before do
        @elasticsearch_original_state_on = Runtime::Search.elasticsearch_on?(api_client)

        unless @elasticsearch_original_state_on
          QA::EE::Resource::Settings::Elasticsearch.fabricate_via_api!
          sleep(60)
          # wait for the change to propagate before inserting records or else
          # Gitlab::CurrentSettings.elasticsearch_indexing and
          # Elastic::ApplicationVersionedSearch::searchable? will be false
          # this sleep can be removed after we're able to query logs via the API
          # as per this issue https://gitlab.com/gitlab-org/quality/team-tasks/issues/395
        end

        Runtime::Project.push_file_to_project(project, 'elasticsearch.rb', "elasticsearch: #{SecureRandom.hex(8)}")
      end

      after do
        if !@elasticsearch_original_state_on && !api_client.nil?
          Runtime::Search.disable_elasticsearch(api_client)
        end
      end

      context 'when searching for projects using advanced syntax' do
        it 'searches in the project name' do
          expect_search_to_find_project("es-adv-*#{project_name_suffix}")
        end

        it 'searches in the project description' do
          expect_search_to_find_project("unique +#{project_name_suffix}")
        end
      end

      private

      def expect_search_to_find_project(search_term)
        QA::Runtime::Env::execute_test_via_api? ? expect_search_to_find_project_via_api(search_term) : expect_search_to_find_project_via_ui(search_term)
      end

      def expect_search_to_find_project_via_api(search_term)
        QA::Support::Retrier.retry_on_exception(max_attempts: 10, sleep_interval: 3) do
          get Runtime::Search.create_search_request(api_client, 'projects', search_term).url
          expect_status(QA::Support::Api::HTTP_STATUS_OK)

          raise 'Empty search result returned' if json_body.empty?

          expect(json_body[0][:name]).to eq(project.name)
        end
      end

      def expect_search_to_find_project_via_ui(search_term)
        Flow::Login.sign_in

        expect { Runtime::Search.find_project(project, search_term) }.not_to raise_error

        Page::Main::Menu.perform do |menu|
          menu.search_for(search_term)
        end

        Page::Search::Results.perform do |results|
          results.switch_to_projects

          results.retry_on_exception(reload: true, sleep_interval: 10) do
            expect(results).to have_content("Advanced search functionality is enabled")
            expect(results).to have_project(project.name)
          end
        end
      end
    end
  end
end
