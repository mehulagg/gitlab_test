# frozen_string_literal: true

module QA
  RSpec.describe 'Package', :docker, :orchestrated, :packages, :geo do
    describe 'Maven Repository' do
      include Runtime::Fixtures

      let(:group_id) { 'com.gitlab.qa' }
      let(:artifact_id) { 'maven' }
      let(:package_name) { "#{group_id}/#{artifact_id}".tr('.', '/') }

      it 'replicates Maven package to the Geo secondary site', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/943' do
        project = nil
        auth_token = nil

        QA::Flow::Login.while_signed_in(address: :geo_primary) do
          project = Resource::Project.fabricate_via_api! do |project|
            project.name = 'mave-geo-package-project'
            project.description = 'Geo project for Maven repo test'
          end

          auth_token = Resource::PersonalAccessToken.fabricate!.access_token

          uri = URI.parse(Runtime::Scenario.gitlab_address)
          gitlab_address_with_port = "#{uri.scheme}://#{uri.host}:#{uri.port}"
          pom_xml = {
            file_path: 'pom.xml',
            content: <<~XML
              <project>
                <groupId>#{group_id}</groupId>
                <artifactId>#{artifact_id}</artifactId>
                <version>1.0</version>
                <modelVersion>4.0.0</modelVersion>
                <repositories>
                  <repository>
                    <id>#{project.name}</id>
                    <url>#{gitlab_address_with_port}/api/v4/projects/#{project.id}/packages/maven</url>
                  </repository>
                </repositories>
                <distributionManagement>
                  <repository>
                    <id>#{project.name}</id>
                    <url>#{gitlab_address_with_port}/api/v4/projects/#{project.id}/packages/maven</url>
                  </repository>
                  <snapshotRepository>
                    <id>#{project.name}</id>
                    <url>#{gitlab_address_with_port}/api/v4/projects/#{project.id}/packages/maven</url>
                  </snapshotRepository>
                </distributionManagement>
              </project>
            XML
          }
          settings_xml = {
            file_path: 'settings.xml',
            content: <<~XML
            <settings xmlns="http://maven.apache.org/SETTINGS/1.1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.1.0 http://maven.apache.org/xsd/settings-1.1.0.xsd">
              <servers>
                <server>
                  <id>#{project.name}</id>
                  <configuration>
                    <httpHeaders>
                      <property>
                        <name>Private-Token</name>
                        <value>#{auth_token}</value>
                      </property>
                    </httpHeaders>
                  </configuration>
                </server>
              </servers>
            </settings>
            XML
          }

          # Use a maven docker container to deploy the package
          with_fixtures([pom_xml, settings_xml]) do |dir|
            Service::DockerRun::Maven.new(dir).publish!
          end

          project.visit!
          Page::Project::Menu.perform(&:click_packages_link)

          Page::Project::Packages::Index.perform do |index|
            expect(index).to have_package(package_name)

            index.click_package(package_name)
          end

          Page::Project::Packages::Show.perform do |show|
            expect(show).to have_package_info(package_name, "1.0")
            # show.click_delete
          end

          # Page::Project::Packages::Index.perform do |index|
          #   expect(index).to have_content("Package was removed")
          #   expect(index).to have_no_package(package_name)
          # end
        end

        QA::Runtime::Logger.debug('Visiting the secondary geo node')

        QA::Flow::Login.while_signed_in(address: :geo_secondary) do
          EE::Page::Main::Banner.perform do |banner|
            expect(banner).to have_secondary_read_only_banner
          end

          Page::Main::Menu.perform { |menu| menu.go_to_projects }

          Page::Dashboard::Projects.perform do |dashboard|
            dashboard.wait_for_project_replication(project.name)
            dashboard.go_to_project(project.name)
          end

          # Validate the content has been sync'd from the primary
          Page::Project::Menu.perform(&:click_packages_link)

          Page::Project::Packages::Index.perform do |index|
            expect(index).to have_package(package_name)

            index.click_package(package_name)
          end

          Page::Project::Packages::Show.perform do |show|
            expect(show).to have_package_info(package_name, "1.0")
          end
        end
      end
    end
  end
end
