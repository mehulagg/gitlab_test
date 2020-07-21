# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        class Sequence
          def initialize(pipeline, command, sequence)
            @pipeline = pipeline
            @command = command
            @sequence = sequence
            @completed = []
            @start = Time.now
          end

          def build!
            applicable_steps.each do |step|
              step.perform!
              break if step.break?

              @completed.push(step)
            end

            @pipeline.tap do
              next if @command.dry_run

              yield @pipeline if block_given?

              @command.observe_creation_duration(Time.now - @start)
              @command.observe_pipeline_size(@pipeline)
            end
          end

          def complete?
            @completed.size == applicable_steps.size
          end

          private

          def applicable_steps
            @applicable_steps ||= all_steps.select(&:applicable?)
          end

          def all_steps
            @all_steps ||= @sequence.map { |step_class| step_class.new(@pipeline, @command) }
          end
        end
      end
    end
  end
end
