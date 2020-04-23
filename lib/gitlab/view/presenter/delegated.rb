# frozen_string_literal: true

module Gitlab
  module View
    module Presenter
      class Delegated
        include Gitlab::View::Presenter::Base

        def initialize(subject, **attributes)
          @subject = subject

          attributes.each do |key, value|
            if subject.respond_to?(key)
              raise CannotOverrideMethodError.new("#{subject} already respond to #{key}!")
            end
          end
        end

        def method_missing(key, *args, &block)
          @_attributes.has_key?(key) ? @_attributes[key] : @subject.__send__(key, *args, &block)
        end
      end
    end
  end
end
