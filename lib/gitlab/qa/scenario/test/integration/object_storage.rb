require 'yaml'

module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class ObjectStorage < Scenario::Template
            include Scenario::CLICommands

            TYPES = %w[artifacts external_diffs lfs uploads packages dependency_proxy].freeze

            def perform(release, *rspec_args)
              Component::Gitlab.perform do |gitlab|
                gitlab.release = release
                gitlab.name = 'gitlab-object-storage'
                gitlab.network = 'test'

                Component::Minio.perform do |minio|
                  minio.network = 'test'

                  TYPES.each do |bucket_name|
                    minio.add_bucket("#{bucket_name}-bucket")
                  end

                  gitlab.omnibus_config = object_storage_config(minio)
                  gitlab.exec_commands = git_lfs_install_commands

                  minio.instance do
                    gitlab.instance do
                      puts 'Running object storage specs!'

                      Component::Specs.perform do |specs|
                        specs.suite = 'Test::Integration::ObjectStorage'
                        specs.release = gitlab.release
                        specs.network = gitlab.network
                        specs.args = [gitlab.address, *rspec_args]
                      end
                    end
                  end
                end
              end
            end

            def object_storage_config(minio)
              TYPES.map do |object_type|
                <<~OMNIBUS
                  gitlab_rails['#{object_type}_enabled'] = true;
                  gitlab_rails['#{object_type}_storage_path'] = '/var/opt/gitlab/gitlab-rails/shared/#{object_type}';
                  gitlab_rails['#{object_type}_object_store_enabled'] = true;
                  gitlab_rails['#{object_type}_object_store_remote_directory'] = '#{object_type}-bucket';
                  gitlab_rails['#{object_type}_object_store_background_upload'] = false;
                  gitlab_rails['#{object_type}_object_store_direct_upload'] = true;
                  gitlab_rails['#{object_type}_object_store_proxy_download'] = true;
                  gitlab_rails['#{object_type}_object_store_connection'] = #{minio.to_config};
                OMNIBUS
              end.join("\n")
            end
          end
        end
      end
    end
  end
end
