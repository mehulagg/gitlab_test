# frozen_string_literal: true

module Gitlab
  module Metrics
    module Dashboard
      module Stages
        class ClusterEmbedFilter < BaseStage
          def transform!
            verify_params

            if @params[:embedded]
              filter_panels_by_params
            end
          end

          private

          def filter_panels_by_params
            @dashboard[:panel_groups].each do |group|
              if group[:group] == @params[:group]
                group[:panels] = group[:panels].filter do |panel|
                  panel[:title] == @params[:title]
                end
              end
            end
          end
        end
      end
    end
  end
end
