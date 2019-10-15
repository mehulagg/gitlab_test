# frozen_string_literal: true

module Elastic
  class CreateIndexService
    attr_accessor :current_user, :params

    def initialize(user, params)
      @current_user, @params = user, params.dup
    end

    def execute
      raise Gitlab::Access::AccessDeniedError unless current_user.admin?

      index = ElasticsearchIndex.new(params)
      return index unless index.valid?

      begin
        Gitlab::Elastic::Helper.create_empty_index(index)
        index.save
      rescue Elasticsearch::Transport::Transport::Error, Faraday::Error => e
        index.errors.add(
          :base,
          _("Error while creating Elasticsearch index, please check your configuration (%{type}: %{message})") % {
            type: e.class.name,
            message: e.message
          }
        )
      end

      index
    end
  end
end
