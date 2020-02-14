# frozen_string_literal: true

module Banzai
  module Filter
    class InlineClusterMetricsFilter < ::Banzai::Filter::InlineEmbedsFilter
      include ::Gitlab::Utils::StrongMemoize

      def create_element(params)
        doc.document.create_element(
          'div',
          class: 'js-render-metrics',
          'data-dashboard-url': metrics_dashboard_url(params)
        )
      end

      def embed_params(node)
        url = node['href']

        return unless [:group, :title, :y_label].all? do |param|
          query_params(url).include?(param)
        end

        query_params(url)
      end

      # def embed_params(node)
      #   url = node['href']
      #
      #   link_pattern.match(url) { |m| m.named_captures }
      # end

      def xpath_search
        "descendant-or-self::a[contains(@href,'clusters') and \
          starts-with(@href, '#{::Gitlab.config.gitlab.url}')]"
      end

      def link_pattern
        ::Gitlab::Metrics::Dashboard::Url.clusters_regex
      end

      def metrics_dashboard_url(params)
        ::Gitlab::Routing.url_helpers.metrics_dashboard_namespace_project_cluster_url(
          namespace_id: params[:namespace],
          project_id: params[:project],
          id: params[:cluster_id],
          # TODO: add admin/group cluster types?
          cluster_type: 'project',
          embedded: true,
          format: 'json',
          **query_params(params['url'])
        )
      end
    end
  end
end
