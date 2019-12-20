# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      class Extendable

        ExtensionError = Class.new(StandardError)

        def initialize(hsh)
          @hash = hsh.to_h.deep_dup


          @hash.each_key do |key|
            entry = Extendable::Entry.new(key, @hash)
            entry.extend! if entry.extensible?
          end
        end

        def to_hash
          @hash.to_h
        end
      end
    end
  end
end
