# frozen_string_literal: true

require 'faker'

module QA
  RSpec.describe 'Verify' do
    describe 'Merge train', :runner do
      let(:group) { Resource::Group.fabricate_via_api! }

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'pipeline-for-merge-train'
          project.group = group
        end
      end

      let!(:runner) do
        Resource::Runner.fabricate_via_api! do |runner|
          runner.token = group.reload!.runners_token
          runner.name = group.name
          runner.tags = [group.name]
        end
      end

      let(:file_name) { 'custom_file.txt' }

      before do
        Flow::Login.sign_in
        project.visit!
        enable_merge_train
        commit_ci_file
      end

      after do
        runner.remove_via_api!
      end

      context 'when system cancel merge request' do
        it 'creates a TODO task' do
          Resource::MergeRequest.fabricate! do |merge_request|
            merge_request.project = project
            merge_request.description = Faker::Lorem.sentence
            merge_request.target_new_branch = !master_branch_exists?
            merge_request.file_name = file_name
            merge_request.file_content = Faker::Lorem.sentence
          end.visit!

          # Create a merge conflict
          Resource::Repository::Commit.fabricate_via_api! do |commit|
            commit.project = project
            commit.commit_message = 'changing text file'
            commit.add_files(
              [
                  {
                      file_path: file_name,
                      content: Faker::Lorem.sentence
                  }
              ]
            )
          end

          Page::MergeRequest::Show.perform(&:try_to_merge!)

          Page::Main::Menu.perform do |main|
            main.goto_page_by_shortcut(:todos_shortcut_button)
          end

          sleep 20
        end
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
                          - #{group.name}
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

      def master_branch_exists?
        project.repository_branches.map { |item| item[:name] }.include?("master")
      end
    end
  end
end
