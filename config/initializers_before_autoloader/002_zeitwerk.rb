# frozen_string_literal: true

Rails.autoloaders.each do |autoloader|
  # We need to ignore these since these are non-Ruby files
  # that do not define Ruby classes / modules
  autoloader.ignore(Rails.root.join('lib/support'))
  # Ignore generators since these are loaded manually by Rails
  autoloader.ignore(Rails.root.join('lib/generators'))
  autoloader.ignore(Rails.root.join('ee/lib/generators')) if Gitlab.ee?
  # Mailer previews are also loaded manually by Rails
  autoloader.ignore(Rails.root.join('app/mailers/previews'))
  autoloader.ignore(Rails.root.join('ee/app/mailers/previews')) if Gitlab.ee?

  autoloader.inflector.inflect(
    'api' => 'API',
    'project_api_compatibility' => 'ProjectAPICompatibility',
    'group_api_compatibility' => 'GroupAPICompatibility',
    'ldap_key' => 'LDAPKey',
    'http' => 'HTTP',
    'http_io' => 'HttpIO',
    'http_connection_adapter' => 'HTTPConnectionAdapter',
    'http_clone_enabled_check' => 'HTTPCloneEnabledCheck',
    'api_guard' => 'APIGuard',
    'binary_stl' => 'BinarySTL',
    'text_stl' => 'TextSTL',
    'sca' => 'SCA',
    'cidr' => 'CIDR',
    'cte' => 'CTE',
    'recursive_cte' => 'RecursiveCTE',
    'sql' => 'SQL',
    'svg' => 'SVG',
    'pdf' => 'PDF',
    'hmac_token' => 'HMACToken',
    'rsa_token' => 'RSAToken',
    'as_json' => 'AsJSON',
    'json' => 'JSON',
    'json_web_token' => 'JSONWebToken',
    'json_formatter' => 'JSONFormatter',
    'html' => 'HTML',
    'html_parser' => 'HTMLParser',
    'html_gitlab' => 'HTMLGitlab',
    'git_user_default_ssh_config_check' => 'GitUserDefaultSSHConfigCheck',
    'git_push_ssh_proxy' => 'GitPushSSHProxy',
    'dn' => 'DN',
    'san_extension' => 'SANExtension',
    'spdx' => 'SPDX',
    'cli' => 'CLI',
    'chunked_io' => 'ChunkedIO',
    'ssh_key' => 'SSHKey',
    'ssh_key_with_user' => 'SSHKeyWithUser',
    'ssh_public_key' => 'SSHPublicKey',
    'function_uri' => 'FunctionURI',
    'mr_note' => 'MRNote'
  )
end
