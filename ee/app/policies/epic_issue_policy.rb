# frozen_string_literal: true

class EpicIssuePolicy < BasePolicy
  delegate { @subject.epic }
end
