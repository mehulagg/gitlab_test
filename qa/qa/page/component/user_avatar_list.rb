# frozen_string_literal: true

module QA
  module Page
    module Component
      module UserAvatarList
        def self.included(base)
          base.view 'app/assets/javascripts/vue_shared/components/user_avatar/user_avatar_list.vue' do
            element :user_avatar_name_content
          end
        end

        def has_user_with_name?(name)
          has_element?(:user_avatar_name_content, name: name)
        end
      end
    end
  end
end
