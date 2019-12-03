require 'yaml'

module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class SMTP < Scenario::Template
            def initialize
              @gitlab_name = 'gitlab-smtp'
              @spec_suite = 'Test::Integration::SMTP'
            end

            attr_reader :gitlab_name, :spec_suite

            def configure_omnibus(gitlab, mail_hog)
              gitlab.omnibus_config = <<~OMNIBUS
                    gitlab_rails['smtp_enable'] = true;
                    gitlab_rails['smtp_address'] = '#{mail_hog.hostname}';
                    gitlab_rails['smtp_port'] = 1025
              OMNIBUS
            end

            def perform(release, *rspec_args)
              release = Release.new(release)

              Component::Gitlab.perform do |gitlab|
                gitlab.release = release
                gitlab.network = 'test'
                gitlab.name = gitlab_name

                Component::MailHog.perform do |mail_hog|
                  mail_hog.network = gitlab.network
                  mail_hog.set_mailhog_hostname

                  configure_omnibus(gitlab, mail_hog)

                  mail_hog.instance do
                    gitlab.instance do
                      puts "Running #{spec_suite} specs!"

                      Component::Specs.perform do |specs|
                        specs.suite = spec_suite
                        specs.release = release
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
