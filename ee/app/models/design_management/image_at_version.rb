# frozen_string_literal: true

class DesignManagement::ImageAtVersion
  # Are immutable, however only cache for 1 day to avoid
  # filling up cache with unviewed designs
  # CACHE_EXPIRY = 1.day

  delegate :design, :version, to: :design_at_version

  def initialize(design_at_version)
    @design_at_version = design_at_version
  end

  def sizes_processing?
    !sizes_processed?
  end

  def sizes_processed?
    # TODO
    # This could be tricky to know ...
    # We can't get the LFS Object without querying gitaly
    # unless we store this value in PG
    true
  end

  def original_url
    url
  end

  # Time-based CACHE if we have N+1 issues, this data is immutable.
  # def original_url
  #   cache { url }
  # end

  def small_url
    return unless sizes_processed?

    url(:small)
  end

  private

  attr_reader :design_at_version

  # If we ever need to mass-expire this cache, touch either Design or Version
  # records to expire their cache keys
  # def cache_key
  #   [self.class.name, design, version]
  # end

  # def cache(&cacheable)
  #   Rails.cache.fetch([cache_key, caller_locations.first.label], expires_in: CACHE_EXPIRY) do
  #     yield cacheable
  #   end
  # end

  # Can we Lazy load the project?
  # I think the project SELECT statement would be cached so may not matter
  def url(size = nil)
    Gitlab::UrlBuilder.build(design, size: size, ref: version.sha)
  end
end
