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

  def self.safe_ensure_unique(retries: 0)
    transaction(requires_new: true) do
      yield
    end
  rescue ActiveRecord::RecordNotUnique
    if retries > 0
      retries -= 1
      retry
    end

    false
  end

  def self.safe_find_or_create_by!(*args)
    safe_find_or_create_by(*args).tap do |record|
      record.validate! unless record.persisted?
    end
  end

  def self.safe_find_or_create_by(*args)
    # we look for object first, as `create_or_find_by`
    # will open a new transaction and always call primary database
    record = find_by(*args)
    return record if record

    create_or_find_by(*args)
  end

  def self.underscore
    Gitlab::SafeRequestStore.fetch("model:#{self}:underscore") { self.to_s.underscore }
  end
end
