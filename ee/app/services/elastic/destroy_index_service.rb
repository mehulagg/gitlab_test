# frozen_string_literal: true

module Elastic
  class DestroyIndexService
    attr_accessor :current_user, :index

    def initialize(user, index)
      @current_user, @index = user, index
    end

    def execute
      raise Gitlab::Access::AccessDeniedError unless current_user.admin?

      if index.id == Gitlab::CurrentSettings.elasticsearch_read_index_id
        index.errors.add(:base, _("Can't delete the active search source"))
        return index
      end

      begin
        Gitlab::Elastic::Helper.delete_index(index)
        index.destroy
      rescue Elasticsearch::Transport::Transport::Error, Faraday::Error => e
        index.errors.add(
          :base,
          _("Error while deleting Elasticsearch index, please check your configuration (%{type}: %{message})") % {
            type: e.class.name,
            message: e.message
          }
        )
      end

      index
    end
  end
end
