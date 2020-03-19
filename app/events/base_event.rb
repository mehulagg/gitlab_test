# frozen_string_literal: true

class BaseEvent
  def initialize(data)
    @data = data
  end

  def listeners
    raise NotImplementedError, 'An array of listeners must be defined'
  end
end
