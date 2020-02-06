# frozen_string_literal: true

# Manages url matching for metrics dashboards.
module EE
  module Gitlab
    module Metrics
      module Dashboard
        module Url
          # Matches dashboard urls for a metric chart embed
          # for cluster metrics
          #
          # EX - https://<host>/<namespace>/<project>/-/clusters/<cluster_id>/?group=Cluster%20Health&title=Memory%20Usage&y_label=Memory%20(GiB)

          def clusters_regex
            %r{
              (?<url>
                #{gitlab_pattern}
                #{project_pattern}
                (?:\/\-)?
                /-
                /clusters
                /(?<cluster_id>\d+)
                [/]?#{query_pattern}
                #{anchor_pattern}
              )
            }x
          end
        end
      end
    end
  end
end
