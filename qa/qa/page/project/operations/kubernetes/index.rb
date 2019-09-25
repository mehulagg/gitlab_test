# frozen_string_literal: true

module QA
  module Page
    module Project
      module Operations
        module Kubernetes
          class Index < Page::Base
            view 'app/views/clusters/clusters/index.html.haml' do
              element :clusters_table
            end

            def add_kubernetes_cluster
              click_on 'Add Kubernetes cluster'
            end

            def has_cluster?(cluster)
              within_element :clusters_table do
                has_text? cluster.to_s
              end
            end
          end
        end
      end
    end
  end
end
