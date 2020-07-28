# frozen_string_literal: true

module FeatureGate
  def flipper_id
    return if new_record?

    # TODO: Should this be `polymorphic_name`
    # to properly support class hierarchies, like `Group < Namespace`
    "#{self.class.name}:#{id}"
  end

  def flipper_actor
    self.class.polymorphic_name
  end
end
