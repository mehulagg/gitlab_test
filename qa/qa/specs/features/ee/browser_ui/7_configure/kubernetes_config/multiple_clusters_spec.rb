# frozen_string_literal: true

module QA
  context 'Configure' do
    describe 'Kubernetes Configuration > Multiple Clusters', :orchestrated, :kubernetes do
      let(:project) do
        Resource::Project.fabricate_via_api! do |p|
          p.name = 'project-with-multiple-k8s-clusters'
          p.description = 'Project that supports multiple K8s clusters'
        end
      end

      before do
        @first_cluster = Service::KubernetesCluster.new.create!
        @second_cluster = Service::KubernetesCluster.new.create!
      end

      after do
        @first_cluster&.remove!
        @second_cluster&.remove!
      end

      it 'supports multiple clusters' do
        login

        Resource::KubernetesCluster.fabricate! do |c|
          c.project = project
          c.cluster = @first_cluster
        end

        Resource::KubernetesCluster.fabricate! do |c|
          c.project = project
          c.cluster = @second_cluster
          c.scope = 'custom/*'
        end

        project.visit!
        Page::Project::Menu.perform(&:go_to_operations_kubernetes)

        Page::Project::Operations::Kubernetes::Index.perform do |index|
          expect(index).to have_cluster(@first_cluster)
          expect(index).to have_cluster(@second_cluster)
        end
      end
    end

    private

    def login
      Runtime::Browser.visit(:gitlab, Page::Main::Login)
      Page::Main::Login.perform(&:sign_in_using_credentials)
    end
  end
end
