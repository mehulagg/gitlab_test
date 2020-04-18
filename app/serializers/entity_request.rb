# frozen_string_literal: true

class EntityRequest
  # We use EntityRequest object to collect parameters and variables
  # from the controller. Because options that are being passed to the entity
  # do appear in each entity object  in the chain, we need a way to pass data
  # that is present in the controller (see  #20045).
  #
  def initialize(parameters)
    @_attributes = parameters
  end

  def method_missing(key, *_)
    @_attributes.has_key?(key) ? @_attributes[key] : super
  end
end
