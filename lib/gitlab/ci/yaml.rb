# frozen_string_literal: true

# The purpose of this class is to bundle together the YamlProcessor
# with a config content being used to run the processor.
# As we use the processor and the content always together it makes
# sense to have a dedicate class that bundles them together.
# This class also provides a safe interfact to use YamlProcessor as
# it collects the generated errors.
module Gitlab
  module Ci
    class Yaml
      attr_reader :content, :processor, :errors, :path

      def initialize(project:, sha: nil, user: nil, content: nil)
        @project = project
        @sha = sha
        @user = user
        # TODO: maybe we can take in input a "path" to a config file
        # instead of the "content" directly. This way we can provide
        # better error messages such as "file my-config.yml not found"
        @path = content.present? ? nil : config_from_project.path
        @content = content || config_from_project.content
        @errors = []
        @processor = initiate_processor!
      end

      def valid?
        @errors.empty?
      end

      def source
        # TODO: what source should we return when the content
        # is passed in from the outside? E.g. child/parent pipelines
        config_from_project.source
      end

      private

      attr_reader :project, :sha, :user

      # TODO: we could merge the Ci::Config new model inside this class
      def config_from_project
        @config_from_project ||= ::Ci::Config.new(project, sha)
      end

      def initiate_processor!
        if content
          ::Gitlab::Ci::YamlProcessor.new(content, { project: project, sha: sha, user: user })
        end
      rescue Gitlab::Ci::YamlProcessor::ValidationError => e
        @errors << e.message
        nil
      rescue
        @errors << 'Undefined error'
        nil
      end
    end
  end
end
