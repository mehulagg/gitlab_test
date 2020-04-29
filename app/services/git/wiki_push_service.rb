# frozen_string_literal: true

module Git
  class WikiPushService < ::ContainerBaseService
    def execute
      # This is used in EE
    end
  end
end

Git::WikiPushService.prepend_if_ee('EE::Git::WikiPushService')
