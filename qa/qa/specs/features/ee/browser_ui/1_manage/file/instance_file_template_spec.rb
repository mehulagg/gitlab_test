# frozen_string_literal: true

module QA
  context 'Manage' do
    describe 'Instance file templates' do
      include Runtime::Fixtures

      templates = [
        {
          type: 'Dockerfile',
          template: 'custom_dockerfile',
          file_path: 'Dockerfile/custom_dockerfile.dockerfile',
          content: 'dockerfile template test'
        },
        {
          type: '.gitignore',
          template: 'custom_gitignore',
          file_path: 'gitignore/custom_gitignore.gitignore',
          content: 'gitignore template test'
        },
        {
          type: '.gitlab-ci.yml',
          template: 'custom_gitlab-ci',
          file_path: 'gitlab-ci/custom_gitlab-ci.yml',
          content: 'gitlab-ci template test'
        },
        {
          type: 'LICENSE',
          template: 'custom_license',
          file_path: 'LICENSE/custom_license.txt',
          content: 'license template test'
        }
      ]

      def login
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform(&:sign_in_using_admin_credentials)
      end

      before(:all) do
        login

        template_group = Resource::Group.fabricate_via_api! do |group|
          group.path = "template-group-#{SecureRandom.hex(8)}"
        end

        test_group = Resource::Group.fabricate_via_api! do |group|
          group.path = "test-group-#{SecureRandom.hex(8)}"
        end

        @file_template_project = Resource::Project.fabricate_via_api! do |project|
          project.group = template_group
          project.name = 'file-template-project'
          project.description = 'Add instance-wide file templates'
          project.initialize_with_readme = true
        end

        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = @file_template_project
          commit.commit_message = 'Add test file templates'
          commit.add_files(templates)
        end

        @project = Resource::Project.fabricate_via_api! do |project|
          project.group = test_group
          project.name = 'file-template-project-2'
          project.description = 'Add files via instance-wide file templates'
          project.initialize_with_readme = true
        end

        Page::Main::Menu.perform(&:sign_out)
      end

      after(:all) do
        login unless Page::Main::Menu.perform(&:signed_in?)

        remove_instance_file_template_if_set

        Page::Main::Menu.perform(&:sign_out)
      end

      templates.each do |template|
        it "creates file via custom #{template[:type]} file template" do
          login
          set_instance_file_template_if_not_already_set
          @project.visit!

          Page::Project::Show.perform(&:create_new_file!)
          Page::File::Form.perform do |form|
            form.select_template template[:type], template[:template]
          end

          expect(page).to have_content(template[:content])

          Page::File::Form.perform(&:commit_changes)

          expect(page).to have_content('The file has been successfully created.')
          expect(page).to have_content(template[:type])
          expect(page).to have_content('Add new file')
          expect(page).to have_content(template[:content])
        end
      end

      def remove_instance_file_template_if_set
        api_client = Runtime::API::Client.new(:gitlab)
        response = get Runtime::API::Request.new(api_client, "/application/settings").url

        if parse_body(response)[:file_template_project_id]
          put Runtime::API::Request.new(api_client, "/application/settings").url, { file_template_project_id: nil }
        end
      end

      def set_instance_file_template_if_not_already_set
        api_client = Runtime::API::Client.new(:gitlab)
        response = get Runtime::API::Request.new(api_client, "/application/settings").url

        if parse_body(response)[:file_template_project_id]
          return
        else
          Page::Main::Menu.perform(&:go_to_admin_area)
          Page::Admin::Menu.perform(&:go_to_template_settings)

          EE::Page::Admin::Settings::Templates.perform do |templates|
            templates.choose_template_repository("#{@file_template_project.name}")
          end

          QA::Support::Retrier.retry_on_exception(max_attempts: 100) do
            fetch_template_from_api('dockerfiles', 'custom_dockerfile')
            fetch_template_from_api('gitignores', 'custom_gitignore')
            fetch_template_from_api('gitlab_ci_ymls', 'custom_gitlab-ci')
            fetch_template_from_api('licenses', 'custom_license')
          end
        end
      end
    end
  end
end
