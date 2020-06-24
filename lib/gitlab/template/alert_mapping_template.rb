# frozen_string_literal: true

module Gitlab
  module Template
    class AlertMappingTemplate < BaseTemplate
      class << self
        def extension
          '.yml'
        end

        def base_dir
         '.gitlab/alert_mapping/'
        end

        def finder(project)
          Gitlab::Template::Finders::RepoTemplateFinder.new(project, self.base_dir, self.extension, self.categories)
        end
      end
    end
  end
end
