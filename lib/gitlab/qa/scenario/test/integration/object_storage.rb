require 'yaml'

module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class ObjectStorage < Scenario::Template
            include Scenario::CLICommands

            def perform(release, *rspec_args)
              Component::Gitlab.perform do |gitlab|
                gitlab.release = release
                gitlab.name = 'gitlab-object-storage'
                gitlab.network = 'test'

                Component::Minio.perform do |minio|
                  minio.network = 'test'
                  ['upload-bucket', 'lfs-bucket'].each do |bucket_name|
                    minio.add_bucket(bucket_name)
                  end

                  gitlab.omnibus_config = <<~OMNIBUS
                    gitlab_rails['uploads_object_store_enabled'] = true;
                    gitlab_rails['uploads_object_store_remote_directory'] = 'upload-bucket';
                    gitlab_rails['uploads_object_store_background_upload'] = false;
                    gitlab_rails['uploads_object_store_direct_upload'] = true;
                    gitlab_rails['uploads_object_store_proxy_download'] = true;
                    gitlab_rails['uploads_object_store_connection'] = #{minio.to_config};
                    gitlab_rails['lfs_enabled'] = true;
                    gitlab_rails['lfs_storage_path'] = '/var/opt/gitlab/gitlab-rails/shared/lfs-objects';
                    gitlab_rails['lfs_object_store_enabled'] = true;
                    gitlab_rails['lfs_object_store_direct_upload'] = true;
                    gitlab_rails['lfs_object_store_background_upload'] = false;
                    gitlab_rails['lfs_object_store_proxy_download'] = false;
                    gitlab_rails['lfs_object_store_remote_directory'] = 'lfs-bucket';
                    gitlab_rails['lfs_object_store_connection'] = #{minio.to_config};
                  OMNIBUS
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
          end
        end
      end
    end
  end
end
