# frozen_string_literal: true

module SamlProviderFinder
  def self.for_group(group)
    return unless ::Gitlab::Auth::GroupSaml::Config.enabled?
    return unless group

    #TODO: consider using a nested hash to avoid poluting keys in SafeRequestStore namespace
    cache_key = "saml_provider_for_group:#{group.id}"
    RequestStoreCache.new(cache_key).cache do
      group.root_ancestor.saml_provider
    end
  end

  class RequestStoreCache
    attr_reader :key

    def initialize(key)
      @key = key
    end

    def cache
      return yield unless cache_store.active?

      return cache_store[key] if cached?

      cache_store[key] = yield
    end

    def cached?
      !cache_store[key].nil?
    end

    private

    def cache_store
      Gitlab::SafeRequestStore
    end
  end
end
