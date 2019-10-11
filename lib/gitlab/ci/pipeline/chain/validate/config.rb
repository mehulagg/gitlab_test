# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        module Validate
          class Config < Chain::Base
            include Chain::Helpers

            def perform!
              unless @pipeline.config_processor
                unless @pipeline.config.content
                  return error("Missing #{@pipeline.config.path} file")
                end

                if @command.save_incompleted && @pipeline.has_yaml_errors?
                  @pipeline.drop!(:config_error)
                end

                error(@pipeline.yaml_errors)
              end
            end

            def break?
              @pipeline.errors.any? || @pipeline.persisted?
            end
          end
        end
      end
    end
  end
end
