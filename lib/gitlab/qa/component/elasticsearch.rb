module Gitlab
  module QA
    module Component
      class Elasticsearch
        include Scenario::Actable

        ELASTIC_IMAGE = 'docker.elastic.co/elasticsearch/elasticsearch'.freeze
        ELASTIC_IMAGE_TAG = '6.4.2'.freeze

        attr_reader :docker
        attr_accessor :environment, :network
        attr_writer :name

        def initialize
          @docker = Docker::Engine.new
          @environment = {}
        end

        def name
          @name ||= "elastic68"
        end

        def instance
          prepare
          start
          yield self
        ensure
          teardown
        end

        def prepare
          @docker.pull(ELASTIC_IMAGE, ELASTIC_IMAGE_TAG)
          return if @docker.network_exists?(network)

          @docker.network_create(network)
        end

        def start
          @docker.run(ELASTIC_IMAGE, ELASTIC_IMAGE_TAG) do |command|
            command << "-d"
            command << "--name #{name}"
            command << "--net #{network}"
            command << "--publish 9200:9200"
            command << "--publish 9300:9300"

            command.env("discovery.type", "single-node")
          end
        end

        def teardown
          @docker.stop(name)
          @docker.remove(name)
        end
      end
    end
  end
end
