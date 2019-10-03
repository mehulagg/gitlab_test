# frozen_string_literal: true

module Elastic
  module MultiVersionUtil
    extend ActiveSupport::Concern
    include Gitlab::Utils::StrongMemoize

    attr_reader :data_class, :data_target

    def version(index)
      version = Elastic.const_get(index.version, false)
      version.const_get(proxy_class_name, false).new(data_target, index)
    end

    # TODO: We want to memoize this, but this breaks with the class-level proxies because they persist across requests.
    # https://gitlab.com/gitlab-org/gitlab/issues/38109
    def elastic_reading_target
      index = Gitlab::CurrentSettings.elasticsearch_read_index
      raise 'No Elasticsearch index configured for reading!' unless index

      version(index)
    end

    # TODO: We want to memoize this, but this breaks with the class-level proxies because they persist across requests.
    # https://gitlab.com/gitlab-org/gitlab/issues/38109
    def elastic_writing_targets
      indices = ElasticsearchIndex.all.to_a
      raise 'No Elasticsearch index configured for writing!' unless indices.present?

      indices.map { |index| version(index) }
    end

    private

    def get_data_class(klass)
      klass < ActiveRecord::Base ? klass.base_class : klass
    end

    # Handles which method calls should be forwarded to all targets,
    # and which calls should be forwarded to just one target.
    #
    # This first sets up forwarding for methods which should go to all targets.
    # This is specified by implementing `methods_for_all_write_targets`.
    # Examples include document indexing/updating operations.
    #
    # Then other methods are forwarded to just the single read target.
    # Examples include user searches.
    #
    # Special write operations specified in `methods_for_one_write_target` are left out.
    # The caller must always specify the version the call should be triggered.
    # Examples include deleting the whole index.
    def generate_forwarding
      methods_for_all_write_targets = elastic_writing_targets.first.real_class.methods_for_all_write_targets
      methods_for_one_write_target = elastic_writing_targets.first.real_class.methods_for_one_write_target

      methods_for_all_write_targets.each do |method|
        self.class.forward_to_all_write_targets(method)
      end

      read_methods = elastic_reading_target.real_class.public_instance_methods
      read_methods -= methods_for_all_write_targets
      read_methods -= methods_for_one_write_target
      read_methods -= self.class.instance_methods
      read_methods.delete(:method_missing)

      read_methods.each do |method|
        self.class.forward_read_method(method)
      end
    end

    class_methods do
      def forward_read_method(method)
        return if respond_to?(method)

        delegate method, to: :elastic_reading_target
      end

      def forward_to_all_write_targets(method)
        return if respond_to?(method)

        define_method(method) do |*args|
          responses = elastic_writing_targets.map do |elastic_target|
            elastic_target.public_send(method, *args) # rubocop:disable GitlabSecurity/PublicSend
          end

          # TODO: This is needed for the retrying logic in Elastic::IndexRecordService.
          # Should we move that further down the stack so we only retry failures on the indices where they failed?
          # TODO: We currently don't retry delete_by_query requests, which report failures in a different format.
          # https://gitlab.com/gitlab-org/gitlab/issues/38111
          responses.find do |response|
            response['_shards'] && response['_shards']['failed'] > 0
          end || responses.last
        end
      end
    end
  end
end
