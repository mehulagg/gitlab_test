require 'securerandom'
require 'net/http'
require 'uri'
require 'forwardable'
require 'openssl'

module Gitlab
  module QA
    module Component
      class Gitlab
        extend Forwardable
        include Scenario::Actable

        attr_reader :release, :docker
        attr_accessor :volumes, :network, :environment, :tls, :disable_animations
        attr_writer :name, :relative_path, :exec_commands

        def_delegators :release, :tag, :image, :edition

        CERTIFICATES_PATH = File.expand_path('../../../../tls_certificates/gitlab'.freeze, __dir__)
        SSL_PATH = '/etc/gitlab/ssl'.freeze

        def initialize
          @docker = Docker::Engine.new
          @environment = {}
          @volumes = {}
          @network_aliases = []
          @disable_animations = true

          @volumes[CERTIFICATES_PATH] = SSL_PATH

          self.release = 'CE'
          self.exec_commands = []
        end

        def omnibus_config=(config)
          @environment['GITLAB_OMNIBUS_CONFIG'] = config.tr("\n", ' ')
        end

        def set_formless_login_token
          return if Runtime::Env.gitlab_qa_formless_login_token.to_s.strip.empty?

          @environment['GITLAB_OMNIBUS_CONFIG'] = "gitlab_rails['env'] = { 'GITLAB_QA_FORMLESS_LOGIN_TOKEN' => '#{Runtime::Env.gitlab_qa_formless_login_token}' }; #{@environment['GITLAB_OMNIBUS_CONFIG'] || ''}"
        end

        def elastic_url=(url)
          @environment['ELASTIC_URL'] = url
        end

        def add_network_alias(name)
          @network_aliases.push(name)
        end

        def release=(release)
          @release = Release.new(release)
        end

        def name
          @name ||= "gitlab-#{edition}-#{SecureRandom.hex(4)}"
        end

        def address
          "#{scheme}://#{hostname}#{relative_path}"
        end

        def scheme
          tls ? 'https' : 'http'
        end

        def port
          tls ? '443' : '80'
        end

        def hostname
          "#{name}.#{network}"
        end

        def relative_path
          @relative_path ||= ''
        end

        def set_accept_insecure_certs
          Runtime::Env.accept_insecure_certs = 'true'
        end

        def instance
          prepare
          start
          reconfigure
          wait
          process_exec_commands

          yield self if block_given?
        ensure
          teardown
        end

        alias_method :launch_and_teardown_instance, :instance

        def prepare
          prepare_gitlab_omnibus_config
          prepare_docker_image
          prepare_network
        end

        def prepare_gitlab_omnibus_config
          setup_disable_animations if disable_animations
          set_formless_login_token
        end

        def prepare_docker_image
          return if Runtime::Env.skip_pull?

          @docker.pull(image, tag)
        end

        def prepare_network
          return if @docker.network_exists?(network)

          @docker.network_create(network)
        end

        def setup_disable_animations
          @environment['GITLAB_OMNIBUS_CONFIG'] = "gitlab_rails['gitlab_disable_animations'] = true; #{@environment['GITLAB_OMNIBUS_CONFIG'] || ''}"
        end

        def start # rubocop:disable Metrics/AbcSize
          ensure_configured!

          if release.dev_gitlab_org?
            Docker::Command.execute(
              [
                'login',
                '--username gitlab-qa-bot',
                %(--password "#{Runtime::Env.dev_access_token_variable}"),
                Release::DEV_REGISTRY
              ]
            )
          end

          docker.run(image, tag) do |command|
            command << "-d -p #{port}"
            command << "--name #{name}"
            command << "--net #{network}"
            command << "--hostname #{hostname}"

            @volumes.to_h.each do |to, from|
              command.volume(to, from, 'Z')
            end

            command.volume(File.join(Runtime::Env.host_artifacts_dir, name, 'logs'), '/var/log/gitlab', 'Z')

            @environment.to_h.each do |key, value|
              command.env(key, value)
            end

            @network_aliases.to_a.each do |network_alias|
              command << "--network-alias #{network_alias}"
            end
          end
        end

        def reconfigure
          @docker.attach(name) do |line, wait|
            puts line
            # TODO, workaround which allows to detach from the container
            #
            Process.kill('INT', wait.pid) if line =~ /gitlab Reconfigured!/
          end
        end

        def restart
          @docker.restart(name)
        end

        def teardown
          raise 'Invalid instance name!' unless name

          @docker.stop(name)
          @docker.remove(name)
        end

        def wait
          if Availability.new(name, relative_path: relative_path, scheme: scheme, protocol_port: port.to_i).check(180)
            sleep 12 # TODO, handle that better
            puts ' -> GitLab is available.'
          else
            abort ' -> GitLab unavailable!'
          end
        end

        def pull
          @docker.pull(@release.image, @release.tag)
        end

        def sha_version
          json = @docker.read_file(
            @release.image, @release.tag,
            '/opt/gitlab/version-manifest.json'
          )

          manifest = JSON.parse(json)
          manifest['software']['gitlab-rails']['locked_version']
        end

        def process_exec_commands
          exec_commands.each { |command| @docker.exec(name, command) }
        end

        private

        attr_reader :exec_commands

        def ensure_configured!
          raise 'Please configure an instance first!' unless [name, release, network].all?
        end

        class Availability
          def initialize(name, relative_path: '', scheme: 'http', protocol_port: 80)
            @docker = Docker::Engine.new

            host = @docker.hostname
            port = @docker.port(name, protocol_port).split(':').last

            @uri = URI.join("#{scheme}://#{host}:#{port}", "#{relative_path}/", 'help')
          end

          def check(retries)
            print "Waiting for GitLab at `#{@uri}` to become available "

            retries.times do
              return true if service_available?

              print '.'
              sleep 1
            end

            false
          end

          private

          def service_available?
            response = Net::HTTP.start(@uri.host, @uri.port, opts) do |http|
              http.head2(@uri.request_uri)
            end

            response.code.to_i == 200
          rescue Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError
            false
          end

          def opts
            @uri.scheme == 'https' ? { use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE } : {}
          end
        end
      end
    end
  end
end
