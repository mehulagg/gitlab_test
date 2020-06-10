# frozen_string_literal: true

module API
  class Wikis < Grape::API
    mount WikisAPI, with: { container: :projects }
  end
end
