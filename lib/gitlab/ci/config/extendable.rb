# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      class Extendable
        attr_accessor :errors

        ExtensionError = Class.new(StandardError)

        def initialize(hsh)
          @hash   = hsh.to_h.deep_dup
          @errors = []

          @hash.each_key do |key|
            entry = Extendable::Entry.new(key, @hash)

            begin
              entry.extend! if entry.extensible?
            rescue ExtensionError => e
              @errors << e.message
              nil
            end
          end
        end

        def to_hash
          @hash.to_h
        end
      end
    end
  end
end
