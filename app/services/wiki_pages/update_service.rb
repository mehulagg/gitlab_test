# frozen_string_literal: true

module WikiPages
  class UpdateService < WikiPages::BaseService
    def execute(page)
      old_slug = page.slug

      if page.update(@params)
        execute_hooks(page, 'update', old_slug)
      end

      page
    end
  end
end
