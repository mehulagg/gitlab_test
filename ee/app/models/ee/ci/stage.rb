# frozen_string_literal: true

module EE
  module Ci
    module Stage
      extend ActiveSupport::Concern

      prepended do
        has_many :downstream_bridges, class_name: ::Ci::Bridges::Downstream
      end
    end
  end
end
