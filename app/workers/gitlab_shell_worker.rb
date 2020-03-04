# frozen_string_literal: true

class GitlabShellWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include Gitlab::ShellAdapter

  feature_category :source_code_management
  urgency :high
  weight 2

  def perform(action, *arg)
    Gitlab::GitalyClient::NamespaceService.allow do
      gitlab_shell.__send__(action, *arg) # rubocop:disable GitlabSecurity/PublicSend
    end
  end
end
