# frozen_string_literal: true

module EE
  module Banzai
    module Filter
      class InlineClusterMetricsFilter < ::Banzai::Filter::InlineEmbedsFilter
        include ::Gitlab::Utils::StrongMemoize

        def create_element(params)
          doc.document.create_element(
            'div',
            class: 'js-render-cluster-metrics',
            'data-dashboard-url': metrics_dashboard_url(params)
          )
        end

        # def embed_params(node)
        #   query_params = ::Gitlab::Metrics::Dashboard::Url.parse_query(node['href'])
        #
        #   # TODO: clarify if always using group/title/y_label provide a guard that won't break at md
        #   # return unless [:group, :title, :y_label].all? do |param|
        #   #   query_params.include?(param)
        #   # end
        #
        #   query_params
        # end
        def embed_params(node)
          url = node['href']

          link_pattern.match(url) { |m| m.named_captures }
        end

        def xpath_search
          "descendant-or-self::a[contains(@href,'clusters') and \
            starts-with(@href, '#{::Gitlab.config.gitlab.url}')]"
        end

        def link_pattern
          ::Gitlab::Metrics::Dashboard::Url.clusters_regex
        end

        def metrics_dashboard_url(params)
          ::Gitlab::Routing.url_helpers.metrics_dashboard_namespace_project_cluster_url(
            namespace_id: params['namespace'],
            project_id: params['project'],
            id: params['cluster_id'],
            # embedded: true,
            # TODO: a admin/group
            cluster_type: 'project',
            embedded: true
          ) + '.json'
        end
      end
    end
  end
end
