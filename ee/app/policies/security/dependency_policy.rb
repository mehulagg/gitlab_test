# frozen_string_literal: true

module Security
  class DependencyPolicy < ::BasePolicy
    delegate { @subject.project }
  end
end
