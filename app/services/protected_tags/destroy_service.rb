# frozen_string_literal: true

module ProtectedTags
  class DestroyService < ::ContainerBaseService
    def execute(protected_tag)
      protected_tag.destroy
    end
  end
end
