# frozen_string_literal: true

module Overcommit::Hook::PrePush
  class GitlabSecurityHarness < Base
    def run
      harness = File.join(File.expand_path(__dir__), '..', '..', '.git', 'security_harness')

      if File.exist?(harness)
        if remote_url.include?('dev.gitlab.org')
          return :pass
        end

        message = "Pushing to remotes other than dev.gitlab.org has been disabled!\nRun scripts/security-harness to disable this check."

        return  [:fail, message]
      end

      :pass
    end
  end
end
