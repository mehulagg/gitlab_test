# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Build
        module Image
          extend ActiveSupport::Concern

          attr_reader :ports

          def initialize(image, job)
            super

            if image.is_a?(Hash) && job.pipeline.webide?
              @ports = build_ports(image).select(&:valid?)
            end
          end

          private

          def build_ports(image)
            image[:ports].to_a.map { |port| ::Gitlab::Ci::Build::Port.new(port) }
          end
        end
      end
    end
  end
end
