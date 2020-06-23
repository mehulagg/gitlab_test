# frozen_string_literal: true

class PatUser
  include PolicyActor
  include Referable

  attr_reader :id, :username, :pat
  def initialize(pat:)
    @username = @id = SecureRandom.hex
    @pat = pat
  end

  def has_access_to?(requested_project)
    pat.project == requested_project
  end
end
