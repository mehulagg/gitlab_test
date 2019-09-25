require 'tmpdir'

module Gitlab
  module QA
    module Docker
      class Volumes
        VOLUMES = { 'config' => '/etc/gitlab',
                    'data' => '/var/opt/gitlab' }.freeze

        QA_CONTAINER_WORKDIR = '/home/gitlab/qa'.freeze

        def initialize(volumes = VOLUMES)
          @volumes = volumes
        end

        def with_temporary_volumes
          # macOS's tmpdir is a symlink /var/folders -> /private/var/folders
          # but Docker on macOS exposes /private and disallow exposing /var/
          # so we need to get the real tmpdir path
          Dir.mktmpdir('gitlab-qa-', File.realpath(Dir.tmpdir)).tap do |dir|
            yield Hash[@volumes.map { |k, v| ["#{dir}/#{k}", v] }]
          end
        end
      end
    end
  end
end
