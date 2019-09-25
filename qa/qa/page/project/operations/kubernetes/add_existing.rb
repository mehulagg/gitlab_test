# frozen_string_literal: true

module QA
  module Page
    module Project
      module Operations
        module Kubernetes
          class AddExisting < Page::Base
            view 'app/views/clusters/clusters/user/_form.html.haml' do
              element :cluster_name_field, required: true
              element :environment_scope
              element :api_url_field, required: true
              element :ca_certificate_field, required: true
              element :service_token_field, required: true
              element :rbac_checkbox
            end

            def set_cluster_name(name)
              fill_element :cluster_name_field, name
            end

            def set_environment_scope(scope)
              fill_element :environment_scope, scope if scope
            end

            def set_api_url(api_url)
              fill_element :api_url_field, api_url
            end

            def set_ca_certificate(ca_certificate)
              fill_element :ca_certificate_field, ca_certificate
            end

            def set_token(token)
              fill_element :service_token_field, token
            end

            def add_cluster!
              click_on 'Add Kubernetes cluster'
            end

            def uncheck_rbac!
              uncheck_element :rbac_checkbox
            end
          end
        end
      end
    end
  end
end
