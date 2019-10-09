require 'yaml'

module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class ObjectStorage < Scenario::Template
            def perform(release, *rspec_args)
              Component::Gitlab.perform do |gitlab|
                gitlab.release = release
                gitlab.name = 'gitlab-object-storage'
                gitlab.network = 'test'

                Component::Minio.perform do |minio|
                  minio.network = 'test'
                  minio.add_bucket('upload-bucket')

                  gitlab.omnibus_config = <<~OMNIBUS
                    gitlab_rails['uploads_object_store_enabled'] = true;
                    gitlab_rails['uploads_object_store_remote_directory'] = 'upload-bucket';
                    gitlab_rails['uploads_object_store_background_upload'] = false;
                    gitlab_rails['uploads_object_store_direct_upload'] = true;
                    gitlab_rails['uploads_object_store_proxy_download'] = true;
                    gitlab_rails['uploads_object_store_connection'] = #{minio.to_config};
                  OMNIBUS

                  minio.instance do
                    gitlab.instance do
                      puts 'Running object store specs!'

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
