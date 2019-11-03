# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        module Validate
          class Config < Chain::Base
            include Chain::Helpers

            def perform!
              @pipeline.config_source = @config.source

              unless @config.processor
                unless @config.content
                  return error("Missing #{@config.path} file")
                end

                @pipeline.yaml_errors = @config.errors.join(', ')

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
