# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        module Config
          class Content
            # This case represents when a config content is passed in
            # as parameter to Ci::CreatePipelineService from the outside.
            # For example when creating a child pipeline.
            class Runtime < Source
              def content
                @command.config_content
              end

              def source
                :runtime_source
              end
            end
          end
        end
      end
    end
  end
end
