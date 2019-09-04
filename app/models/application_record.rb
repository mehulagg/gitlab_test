# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  alias_method :reset, :reload

  def self.id_in(ids)
    where(id: ids)
  end

  def self.id_not_in(ids)
    where.not(id: ids)
  end

  def self.pluck_primary_key
    where(nil).pluck(self.primary_key)
  end

  def self.safe_ensure_unique(retries: 0, before_retry: nil, on_rescue: false)
    transaction(requires_new: true) do
      yield
    end
  rescue ActiveRecord::RecordNotUnique # rubocop: disable SafeEnsureUnique
    if retries > 0
      retries -= 1
      before_retry.call if before_retry.respond_to?(:call)
      retry
    end

    on_rescue.respond_to?(:call) ? on_rescue.call : on_rescue
  end

  def self.safe_find_or_create_by!(*args)
    safe_find_or_create_by(*args).tap do |record|
      record.validate! unless record.persisted?
    end
  end

  def self.safe_find_or_create_by(*args)
    safe_ensure_unique(retries: 1) do
      find_or_create_by(*args)
    end
  end

  def self.underscore
    Gitlab::SafeRequestStore.fetch("model:#{self}:underscore") { self.to_s.underscore }
  end
end
