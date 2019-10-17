module Gitlab
  module QA
    module Scenario
      module Test
        module Instance
          class RelativeUrl < Image
            def perform(release, *rspec_args)
              Component::Gitlab.perform do |gitlab|
                gitlab.release = release
                gitlab.network = 'test'
                gitlab.relative_path = '/relative'

                gitlab.omnibus_config = <<~OMNIBUS
                  external_url '#{gitlab.address}';
                OMNIBUS

                gitlab.instance do
                  Component::Specs.perform do |specs|
                    specs.suite = 'Test::Instance::All'
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
