# frozen_string_literal: true

module EE
  module StubGitlabCalls
    def stub_webide_config_file(content, sha: anything)
      allow_any_instance_of(Repository)
        .to receive(:blob_data_at).with(sha, '.gitlab/.gitlab-webide.yml')
        .and_return(content)

      # stub any possible calls for gitlab_ci_yml_for that can
      # occur in Ci::Config as part of auto-loading of config data
      allow_any_instance_of(Repository)
        .to receive(:gitlab_ci_yml_for).with(sha, anything)
        .and_return(content)
    end

    def stub_registry_replication_config(registry_settings)
      allow(::Gitlab.config.geo.registry_replication).to receive_messages(registry_settings)
      allow(Auth::ContainerRegistryAuthenticationService)
        .to receive(:pull_access_token).and_return('pull-token')
    end
  end
end
