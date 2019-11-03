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
                # TODO: remove this comment:
                # this was originally in the pipeline.config_processor error handling
                @pipeline.yaml_errors = @config.errors.join(', ')

                # TODO: we could have this error generated inside @config and
                # appended to @config.errors
                unless @config.content
                  return error("Missing #{@config.path} file")
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
