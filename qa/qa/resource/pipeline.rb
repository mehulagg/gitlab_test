# frozen_string_literal: true

module QA
  module Resource
    # Pipeline API resource
    # See https://docs.gitlab.com/ee/api/pipelines.html
    class Pipeline < Base
      attribute :project do
        Resource::Project.fabricate! do |project|
          project.name = 'project-with-pipeline'
        end
      end

      attribute :id
      attribute :status
      attribute :ref
      attribute :sha

      # array in form
      # [
      #   { key: 'UPLOAD_TO_S3', variable_type: 'file', value: true },
      #   { key: 'SOMETHING', variable_type: 'variable', value: 'yes' }
      # ]
      attribute :variables

      def initialize
        @ref = 'master'
        @variables = []
      end

      # Convenience method for adding variables to the resource
      #
      # @example
      #
      #   add_variable(key: 'FOO', value: 'bar')
      #   add_variable(key: 'BAZ', value: 'qux', variable_type: 'file')
      #
      # @param [String] key CI Variable Key
      # @param [String] value CI Variable Value
      # @param [String] variable_type CI Variable Type
      def add_variable(key:, value:, variable_type: 'variable')
        @variables << { key: key, value: value, variable_type: variable_type }
      end

      def fabricate!
        project.visit!

        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:click_run_pipeline_button)
        Page::Project::Pipeline::New.perform(&:click_run_pipeline_button)
      end

      def fabricate_via_api!
        resource_web_url(api_get)
      rescue ResourceNotFoundError
        super
      end

      def api_get_path
        "/projects/#{project.id}/pipelines/#{id}"
      end

      def api_post_path
        "/projects/#{project.id}/pipeline"
      end

      def api_post_body
        {
          ref: ref,
          variables: variables
        }
      end
    end
  end
end
