# frozen_string_literal: true

class AccessibilityErrorEntity < Grape::Entity
  expose :code do |error|
    error["code"]
  end

  expose :type do |error|
    error["type"]
  end

  expose :type_code do |error|
    error["typeCode"]
  end

  expose :message do |error|
    error["message"]
  end

  expose :context do |error|
    error["context"]
  end

  expose :selector do |error|
    error["selector"]
  end

  expose :runner do |error|
    error["runner"]
  end

  expose :runner_extras do |error|
    error["runnerExtras"]
  end
end
