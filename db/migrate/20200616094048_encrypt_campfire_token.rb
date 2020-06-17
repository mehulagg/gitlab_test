# frozen_string_literal: true

class EncryptCampfireToken < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  class Service < ActiveRecord::Base
    self.table_name = 'services'
  end

  class CampfireService < Service
    # This wouldn't work withou JSONB
    store :properties, accessors: %i[encrypted_token encrypted_token_iv], coder: JSON
    attr_encrypted :token, key: Settings.attr_encrypted_db_key_base_32, encode: true, mode: :per_attribute_iv, algorithm: 'aes-256-gcm'

    def self.store_full_sti_class
      false
    end
  end

  def up
    CampfireService.all.each do |service|
      properties = Gitlab::Json.parse(service.properties)
      next if properties.key?('encrypted_token') && properties.key?('encrypted_token_iv')

      service.token = properties['token']
      service.save!(validate: false)
    end
  end

  def down
    # When properties has jsonB type we can do something like
    # UPDATE services SET properties = properties - 'encrypted_token' WHERE type = 'CampfireService'

    CampfireService.all.each do |service|
      next unless service.properties.key?('encrypted_token') || service.properties.key?('encrypted_token_iv')

      service.properties = service.properties.except('encrypted_token', 'encrypted_token_iv')
      service.save!(validate: false)
    end
  end
end
