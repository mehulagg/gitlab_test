# frozen_string_literal: true

class BaseSerializer
  attr_reader :params, :context

  def initialize(params = {})
    @context = params.delete(:context)
    @params = params
    @request = EntityRequest.new(params)
  end

  def represent(resource, opts = {}, entity_class = nil)
    entity_class ||= self.class.entity_class

    entity_class
      .represent(resource, opts.merge(request: @request, context: context))
      .as_json
  end

  class << self
    attr_reader :entity_class

    def entity(entity_class)
      @entity_class ||= entity_class
    end
  end
end
