# frozen_string_literal: true

class GroupPipelinesFinder
  include Gitlab::Allowable

  def initialize(current_user)
    @current_user = current_user
  end

  def execute(*params)
  end
end
