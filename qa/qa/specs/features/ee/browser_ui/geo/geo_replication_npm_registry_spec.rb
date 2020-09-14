# frozen_string_literal: true

module QA
  RSpec.describe 'Geo', :orchestrated, :geo do
    describe 'GitLab Geo NPM registry replication' do
      include Runtime::Fixtures

      # Test code is based on qa/specs/features/browser_ui/5_package/npm_registry_spec.rb
      # Issue to reduce code duplication in Geo specs: https://gitlab.com/gitlab-org/quality/team-tasks/-/issues/637
      it 'replicates NPM registry to secondary Geo site', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1026' do
        project = nil

        QA::Flow::Login.while_signed_in(address: :geo_primary) do
          project = Resource::Project.fabricate_via_api! do |project|
            project.name = 'geo-npm-package-project'
            project.description = 'Geo project for NPM package replication test'
          end

          auth_token = Resource::PersonalAccessToken.fabricate!.access_token
          uri = URI.parse(Runtime::Scenario.gitlab_address)
          gitlab_host_with_port = "#{uri.host}:#{uri.port}"
          gitlab_address_with_port = "#{uri.scheme}://#{uri.host}:#{uri.port}"
          registry_scope = project.group.sandbox.path
          package_name = "@#{registry_scope}/#{project.name}"
          version = "1.0.0"
          package_json = {
            file_path: 'package.json',
            content: <<~JSON
              {
                "name": "#{package_name}",
                "version": "#{version}",
                "description": "Example package for GitLab NPM registry",
                "publishConfig": {
                  "@#{registry_scope}:registry": "#{gitlab_address_with_port}/api/v4/projects/#{project.id}/packages/npm/"
                }
              }
            JSON
          }
          npmrc = {
            file_path: '.npmrc',
            content: <<~NPMRC
              //#{gitlab_host_with_port}/api/v4/projects/#{project.id}/packages/npm/:_authToken=#{auth_token}
              //#{gitlab_host_with_port}/api/v4/packages/npm/:_authToken=#{auth_token}
              @#{registry_scope}:registry=#{gitlab_address_with_port}/api/v4/packages/npm/
            NPMRC
          }

          # Use a Node Docker container to publish the package
          with_fixtures([npmrc, package_json]) do |dir|
            Service::DockerRun::NodeJs.new(dir).publish!
          end

          # Check to make sure package appears on the primary Geo site
          project.visit!
          confirm_package_content(package_name, version)
        end

        QA::Runtime::Logger.debug('Visiting the secondary Geo site')

        QA::Flow::Login.while_signed_in(address: :geo_secondary) do
          EE::Page::Main::Banner.perform do |banner|
            expect(banner).to have_secondary_read_only_banner
          end

          Page::Main::Menu.perform { |menu| menu.go_to_projects }

          Page::Dashboard::Projects.perform do |dashboard|
            dashboard.wait_for_project_replication(project.name)
            dashboard.go_to_project(project.name)
          end

          confirm_package_content(package_name, version)
        end

        def confirm_package_content(package_name, version)
          Page::Project::Menu.perform(&:click_packages_link)

          Page::Project::Packages::Index.perform do |index|
            expect(index).to have_package(package_name)

            index.click_package(package_name)
          end

          Page::Project::Packages::Show.perform do |show|
            expect(show).to have_package_info(package_name, version)
          end
        end
      end
    end
  end
end
