# frozen_string_literal: true

module API
  class GroupWikis < Grape::API
    mount WikisAPI, with: { container: :groups }
  end
end
