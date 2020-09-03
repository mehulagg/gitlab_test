# frozen_string_literal: true

require 'faker'

module QA
  RSpec.describe 'Verify', :docker, :runner do
    describe 'In merge trains' do
      context 'new thread discussions' do
        let(:executor) { "qa-runner-#{Time.now.to_i}" }
        let(:file_name) { 'custom_file.txt' }
        let!(:runner) do
          Resource::Runner.fabricate! do |runner|
            runner.project = project
            runner.name = executor
            runner.tags = [executor]
          end
        end

        let(:project) do
          Resource::Project.fabricate_via_api! do |project|
            project.name = 'pipeline-for-merge-trains'
          end
        end

        let(:merge_request) do
          Resource::MergeRequest.fabricate_via_api! do |merge_request|
            merge_request.project = project
            merge_request.description = Faker::Lorem.sentence
            merge_request.target_new_branch = false
            merge_request.file_name = file_name
            merge_request.file_content = Faker::Lorem.sentence
          end
        end

        before do
          Flow::Login.sign_in
          project.visit!

          enable_merge_train
          commit_ci_file

          merge_request.visit!
          Page::MergeRequest::Show.perform(&:try_to_merge!)
          start_discussion
        end

        after do
          runner.remove_via_api!
        end

        it 'do not drop MRs' do
          # expect something magical here
        end

        private

        def enable_merge_train
          Page::Project::Menu.perform(&:go_to_general_settings)
          Page::Project::Settings::Main.perform do |main|
            main.expand_merge_requests_settings do |settings|
              settings.click_pipelines_for_merged_results_checkbox
              settings.click_save_changes
            end
          end
        end

        def commit_ci_file
          Resource::Repository::Commit.fabricate_via_api! do |commit|
            commit.project = project
            commit.commit_message = 'Add .gitlab-ci.yml'
            commit.add_files(
              [
                  {
                      file_path: '.gitlab-ci.yml',
                      content: <<~YAML
                        test_merge_train:
                          tags:
                            - #{executor}
                          script:
                            - |
                              sleep 5
                              echo 'Yawn!'
                          only:
                            - merge_requests
                      YAML
                  }
              ]
            )
          end
        end

        def start_discussion
          Page::MergeRequest::Show.perform do |show|
            show.click_discussions_tab
            show.start_discussion(Faker::Lorem.sentence)
          end
        end
      end
    end
  end
end
