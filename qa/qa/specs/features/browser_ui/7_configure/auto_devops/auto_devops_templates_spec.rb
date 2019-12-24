# frozen_string_literal: true

module QA
  context 'Configure' do
    describe 'AutoDevOps Templates', :docker do
      using RSpec::Parameterized::TableSyntax

      let(:optional_jobs) do
        %w[
          LICENSE_MANAGEMENT_DISABLED
          SAST_DISABLED DAST_DISABLED
          DEPENDENCY_SCANNING_DISABLED
          CONTAINER_SCANNING_DISABLED
        ]
      end

      where(:template) do
        %w[rails spring express]
      end

      with_them do
        let!(:executor) { "qa-runner-#{Time.now.to_i}" }
        let(:project) do
          Resource::Project.fabricate_via_api! do |project|
            project.name = "#{template}-project-template-with-autodevops"
            project.template_name = template
            project.description = "Let's see if the #{template} project works..."
            project.auto_devops_enabled = true
          end
        end

        let(:runner) do
          Resource::Runner.fabricate! do |runner|
            runner.project = project
            runner.name = executor
            runner.tags = [executor]
          end
        end

        let(:pipeline) do
          Resource::Pipeline.fabricate_via_api! do |pipeline|
            pipeline.project = project

            optional_jobs.each do |key|
              pipeline.add_variable(key: key, value: '1')
            end
          end
        end

        before do
          Flow::Login.sign_in
          pipeline.visit!
        end

        it "works with AutoDevOps" do
          validate_jobs
        end
      end

      private

      def validate_jobs
        %w[build code_quality test].each do |job|
          Page::Project::Pipeline::Show.perform do |show_page|
            show_page.click_job(job)
          end

          Page::Project::Job::Show.perform do |show|
            expect(show).to be_passed(timeout: 600)
            show.click_element(:pipeline_path)
          end
        end
      end
    end
  end
end
