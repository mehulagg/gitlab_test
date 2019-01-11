# frozen_string_literal: true

class WebRequestContext
  attr_reader :session

  def initialize(session)
    @session = session
  end
end
