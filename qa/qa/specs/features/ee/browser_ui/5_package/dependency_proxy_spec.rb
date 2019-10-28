# frozen_string_literal: true

module QA
  context 'Package', :docker, :packages do
    describe 'Dependency Proxy' do
      it 'pulls from the gitlab proxy' do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform(&:sign_in_using_credentials)

        group = Resource::Group.fabricate_via_api!
        Service::DockerRun::DependencyProxy.new(group).pull!

        group.visit!

        EE::Page::Group::SubMenus::Packages.perform(&:go_to_dependency_proxy)

        expect(page).to have_text 'Contains 1 blobs of images'
      end
    end
  end
end
