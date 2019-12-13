# frozen_string_literal: true

module Security
  class DependencyPolicy < ::BasePolicy
    delegate { @subject.issue }
  end
end
