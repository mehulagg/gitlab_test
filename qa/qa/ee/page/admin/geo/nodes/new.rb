module QA
  module EE
    module Page
      module Admin
        module Geo
          module Nodes
            class New < QA::Page::Base
              view 'ee/app/views/admin/geo/nodes/_form.html.haml' do
                element :node_url_field, 'text_field :url' # rubocop:disable QA/ElementWithPattern
                element :node_url_placeholder, "label :url" # rubocop:disable QA/ElementWithPattern
              end

              view 'ee/app/views/admin/geo/nodes/new.html.haml' do
                element :add_node_button, "submit 'Add Node'" # rubocop:disable QA/ElementWithPattern
              end

              def set_node_address(address)
                fill_in 'URL', with: address
              end

              def add_node!
                click_button 'Add Node'
              end
            end
          end
        end
      end
    end
  end
end
