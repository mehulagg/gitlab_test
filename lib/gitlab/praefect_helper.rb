# frozen_string_literal: true
require 'toml-rb'

module Gitlab
  class PraefectHelper < Gitlab::GitalyHelper
    def self.config_file
      'praefect.config.toml'
    end

    def self.configuration_toml(gitaly_dir, storage_paths)
      address = nil

      Gitlab.config.repositories.storages.each do |key, val|
        validate_repositories(address, val)
        address = val['gitaly_address']
      end

      nodes = [{ storage: 'praefect-gitaly', address: gitaly_address(gitaly_dir), primary: true, token: 'secret' }]

      config = { socket_path: address.sub(/\Aunix:/, ''), virtual_storage_name: 'default' }
      config[:auth] = { token: 'secret' } if Rails.env.test?
      config[:node] = nodes

      TomlRB.dump(config)
    end
  end
end
