# frozen_string_literal: true

Rails.autoloaders.each do |autoloader|
  # We need to ignore these since these are non-Ruby files
  # that do not define Ruby classes / modules
  autoloader.ignore(Rails.root.join('lib/support'))

  autoloader.inflector.inflect(
    'api' => 'API',
    'project_api_compatibility' => 'ProjectAPICompatibility',
    'group_api_compatibility' => 'GroupAPICompatibility',
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
    'ldaps_controller' => 'LDAPsController',
    'html' => 'HTML',
    'html_parser' => 'HTMLParser',
    'html_gitlab' => 'HTMLGitlab',
    'git_user_default_ssh_config_check' => 'GitUserDefaultSSHConfigCheck',
    'git_push_ssh_proxy' => 'GitPushSSHProxy',
    'dn' => 'DN',
    'saml' => 'SAML',
    'san_extension' => 'SANExtension',
    'spdx' => 'SPDX',
    'cli' => 'CLI',
    'chunked_io' => 'ChunkedIO',
    'ssh_public_key' => 'SSHPublicKey'
  )
end
