# frozen_string_literal: true

module QA
  context 'Create' do
    describe 'Web IDE web terminal file sync', :orchestrated, :kubernetes do
      before do
        @project = Resource::Project.fabricate_via_api! do |project|
          project.name = 'web-terminal-file-sync-project'
        end

        @cluster = Service::KubernetesCluster.new.create!

        Resource::KubernetesCluster.fabricate! do |cluster|
          cluster.project = @project
          cluster.cluster = @cluster
          cluster.install_helm_tiller = true
          cluster.install_ingress = true
          cluster.install_prometheus = true
          cluster.install_runner = true
        end

        Resource::Repository::Commit.fabricate_via_api! do |push|
          push.project = @project
          push.commit_message = 'Add .gitlab/.gitlab-webide.yml'
          push.files = [
            {
                file_path: '.gitlab/.gitlab-webide.yml',
                content: <<~YAML
                  terminal:
                    script: sleep 60
                    services:
                    - name: registry.gitlab.com/gitlab-org/webide-file-sync:latest
                      alias: webide-file-sync
                      entrypoint: ["/bin/sh"]
                      command: ["-c", "sleep 5 && ./webide-file-sync -port 5000 -project-dir $CI_PROJECT_DIR"]
                      ports:
                        - number: 5000
                YAML
            }
          ]
        end

        # Configure the runner on kubernetes
        # Must expose port 8093

        # @runner = Resource::Runner.fabricate_via_api! do |runner|
        #   runner.project = @project
        #   runner.name = "qa-runner-#{Time.now.to_i}"
        #   runner.tags = %w[qa docker web-ide]
        #   runner.image = 'gitlab/gitlab-runner:latest'
        #   runner.config = <<~END
        #     concurrent = 1

        #     [session_server]
        #       listen_address = "0.0.0.0:8093"
        #       advertise_address = "#{@cluster.ingress_ip}:8093"
        #       session_timeout = 120
        #   END
        # end

        Page::Main::Menu.perform(&:sign_out)
      end

      after do
        @cluster&.remove!
      end

      it 'user starts the web terminal with file sync enabled' do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Page::Main::Login.perform(&:sign_in_using_credentials)

        @project.visit!
        Page::Project::Show.perform(&:open_web_ide!)

        # Start the web terminal and check that there were no errors
        # The terminal screen is a canvas element, so we can't read its content,
        # so we infer that it's working if:
        #  a) The terminal JS package has loaded, and
        #  b) It's not stuck in a "Loading/Starting" state, and
        #  c) There's no alert stating there was a problem
        #
        # The terminal itself is a third-party package so we assume it is
        # adequately tested elsewhere.
        #
        # There are also FE specs
        # * ee/spec/javascripts/ide/components/terminal/terminal_spec.js
        # * ee/spec/frontend/ide/components/terminal/terminal_controls_spec.js
        Page::Project::WebIDE::Edit.perform do |edit|
          edit.start_web_terminal

          expect(edit).to have_no_alert
          expect(edit).to have_finished_loading
          expect(edit).to have_terminal_screen
        end
      end
    end
  end
end
