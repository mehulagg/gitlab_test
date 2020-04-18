# frozen_string_literal: true

module Gitlab
  module View
    module Presenter
      class Simple
        include Gitlab::View::Presenter::Base

        def initialize(subject, **attributes)
          @subject = subject

          @_attributes = attributes
        end

        def method_missing(key, *_)
          @_attributes.has_key?(key) ? @_attributes[key] : super
        end
      end
    end
  end
end
