# frozen_string_literal: true

module QA
  context 'Geo', :orchestrated, :geo do
    describe 'GitLab Geo project rename replication' do
      it 'user renames project' do
        # create the project and push code
        Runtime::Browser.visit(:geo_primary, QA::Page::Main::Login) do
          Page::Main::Login.act { sign_in_using_credentials }

          project = Resource::Project.fabricate! do |project|
            project.name = 'geo-before-rename'
            project.description = 'Geo project to be renamed'
          end

          geo_project_name = project.name
          expect(project.name).to include 'geo-before-rename'

          Resource::Repository::ProjectPush.fabricate! do |push|
            push.project = project
            push.file_name = 'README.md'
            push.file_content = '# This is Geo project!'
            push.commit_message = 'Add README.md'
          end

          # rename the project
          Page::Main::Menu.act { go_to_projects }

          Page::Dashboard::Projects.perform do |dashboard|
            dashboard.go_to_project(geo_project_name)
          end

          Page::Project::Menu.act { click_settings }

          geo_project_renamed = "geo-after-rename-#{SecureRandom.hex(8)}"
          Page::Project::Settings::Main.perform do |settings|
            settings.expand_advanced_settings do |page|
              page.rename_to(geo_project_renamed)
            end
          end

          # check renamed project exist on secondary node
          Runtime::Browser.visit(:geo_secondary, QA::Page::Main::Login) do
            Page::Main::OAuth.act do
              authorize! if needs_authorization?
            end

            EE::Page::Main::Banner.perform do |banner|
              expect(banner).to have_secondary_read_only_banner
            end

            Page::Main::Menu.perform do |menu|
              menu.go_to_projects
            end

            Page::Dashboard::Projects.perform do |dashboard|
              dashboard.wait_for_project_replication(geo_project_renamed)

              dashboard.go_to_project(geo_project_renamed)
            end

            Page::Project::Show.perform do |show|
              show.wait_for_repository_replication

              expect(page).to have_content 'README.md'
              expect(page).to have_content 'This is Geo project!'
            end
          end
        end
      end
    end
  end
end
