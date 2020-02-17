module Gitlab
  module QA
    module Scenario
      module Test
        module Instance
          class RepositoryStorage < Image
            def perform(release, *rspec_args)
              Component::Gitlab.perform do |gitlab|
                gitlab.release = Release.new(release)
                gitlab.name = 'gitlab'
                gitlab.network = 'test'
                gitlab.omnibus_config = <<~OMNIBUS
                  git_data_dirs({
                    'default' => {
                      'path' => '/var/opt/gitlab/git-data/repositories/default'
                    },
                    'secondary' => {
                      'path' => '/var/opt/gitlab/git-data/repositories/secondary'
                    }
                  });
                OMNIBUS

                rspec_args << "--" unless rspec_args.include?('--')
                rspec_args << %w[--tag repository_storage]

                gitlab.instance do
                  Component::Specs.perform do |specs|
                    specs.suite = 'Test::Instance::All'
                    specs.release = gitlab.release
                    specs.network = gitlab.network
                    specs.args = [gitlab.address, *rspec_args]
                    specs.env = { 'QA_ADDITIONAL_REPOSITORY_STORAGE' => 'secondary' }
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
