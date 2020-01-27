# frozen_string_literal: true

module Projects::VaultIntegrationHelper
  def vault_integration_data(project)
    {
      operations_settings_endpoint: project_settings_operations_path(project),
      vault_integration: vault_integration_attributes(project)
    }
  end

  private

  def vault_integration_attributes(project)
    {
      url: vault_integration_url(project),
      token: vault_integration_token(project),
      enabled: vault_integration_enabled?(project),
      ssl_pem_contents: vault_integration_ssl_pem_contents(project),
      protected_secrets: vault_integration_protected_secrets(project)
    }
  end

  def vault_integration_url(project)
    project.vault_integration&.vault_url
  end

  def vault_integration_token(project)
    project.vault_integration&.token.presence && ('*' * 12)
  end

  def vault_integration_ssl_pem_contents(project)
    project.vault_integration&.ssl_pem_contents.presence && ('*' * 12)
  end

  def vault_integration_enabled?(project)
    project.vault_integration&.enabled?.to_s
  end

  def vault_integration_protected_secrets(project)
    project.vault_integration&.protected_secrets.to_a.join("\n")
  end
end
