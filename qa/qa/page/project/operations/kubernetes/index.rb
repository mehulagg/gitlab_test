# frozen_string_literal: true

module QA
  module Page
    module Project
      module Operations
        module Kubernetes
          class Index < Page::Base
            view 'app/views/clusters/clusters/_empty_state.html.haml' do
              element :add_kubernetes_cluster_button, "link_to s_('ClusterIntegration|Add Kubernetes cluster')" # rubocop:disable QA/ElementWithPattern
            end

            view 'app/views/clusters/clusters/index.html.haml' do
              element :clusters_table
            end

            def add_kubernetes_cluster
              click_on 'Add Kubernetes cluster'
            end

            def has_cluster?(cluster)
              within_element :clusters_table do
                !!find('a', text: cluster.to_s)
              end
            end
          end
        end
      end
    end
  end
end
