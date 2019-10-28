# frozen_string_literal: true

module QA
  module EE
    module Page
      module Group
        module SubMenus
          class Packages < QA::Page::Base
            include QA::Page::Group::SubMenus::Common

            view 'ee/app/views/groups/sidebar/_packages.html.haml' do
              element :packages_link
              element :dependency_proxy_link
            end

            def go_to_dependency_proxy
              hover_packages do
                click_element(:dependency_proxy_link)
              end
            end

            private

            def hover_packages
              within_sidebar do
                scroll_to_element(:packages_link)
                find_element(:packages_link).hover

                yield
              end
            end
          end
        end
      end
    end
  end
end
