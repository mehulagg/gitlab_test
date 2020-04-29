# frozen_string_literal: true

class ContainerBaseService < ::BaseService
  attr_reader :container
  attr_accessor :project # legacy support

  delegate :repository, to: :project

  def initialize(container, user = nil, params = {})
    @container = container
    @project = container # legacy support

    super(user, params)
  end
end
