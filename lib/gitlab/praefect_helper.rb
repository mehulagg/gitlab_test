# frozen_string_literal: true
require 'toml-rb'

module Gitlab
  module PraefectHelper
    class << self
      def praefect_configuration_toml(gitaly_dir, storage_paths)
        address = nil

        Gitlab.config.repositories.storages.each do |key, val|
          address = val['gitaly_address'] if key == 'praefect'
        end

        nodes = [{ storage: 'praefect-gitaly', address: gitaly_address(gitaly_dir), primary: true, token: 'secret' }]

        config = { socket_path: address.sub(/\Aunix:/, ''), virtual_storage_name: 'praefect' }
        config[:auth] = { token: 'secret' } if Rails.env.test?
        config[:node] = nodes

        TomlRB.dump(config)
      end

      def create_praefect_configuration(dir, storage_paths, force: false)
        Gitlab::SetupHelper.create_configuration(
          praefect_configuration_toml(dir, storage_paths),
          praefect_config_path(dir),
          force: force
        )
      end

      def praefect_config_path(dir)
        File.join(dir, 'praefect.config.toml')
      end

      def gitaly_address(gitaly_dir)
        "unix:#{gitaly_dir}/gitaly.socket"
      end
    end
  end
end
