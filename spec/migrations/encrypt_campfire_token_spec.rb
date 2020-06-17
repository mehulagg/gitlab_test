# frozen_string_literal: true

require 'spec_helper'

require Rails.root.join('db', 'migrate', '20200616094048_encrypt_campfire_token.rb')

describe EncryptCampfireToken do
  let(:migration) { described_class.new }
  let(:services) { table(:services) }
  let(:properties_with_just_token) { { token: 'some_token' }.to_json }
  let(:properties_with_encrypted_token) { { token: 'some_token', encrypted_token: 'encrypted_123', encrypted_token_iv: 'encrypted_123_iv' }.to_json }

  xdescribe '#up' do
    before do
      services.create!(type: 'CampfireService', properties: properties_with_just_token )
      services.create!(type: 'CampfireService', properties: properties_with_encrypted_token )
      services.create!(type: 'OtherType', properties: properties_with_just_token )
    end

    it 'encrypts all CampfireService tokens', :aggregate_failures do
      migration.up

      services.where(type: 'CampfireService').each do |service|
        properties = Gitlab::Json.parse(service.properties)

        expect(properties.fetch('token')).to eq('some_token')
        expect(properties.fetch('encrypted_token')).not_to eq(nil)
        expect(properties.fetch('encrypted_token_iv')).not_to eq(nil)
      end
    end

    it 'skips services that already have encrypted tokens' do
      migration.up

      expect(services.where(type: 'CampfireService', properties: properties_with_encrypted_token).count).to eq(1)
    end

    it 'does not touch services of other types', :aggregate_failures do
      migration.up

      services.where.not(type: 'CampfireService').each do |service|
        properties = Gitlab::Json.parse(service.properties)

        expect(properties.key?('encrypted_token')).to be_falsy
        expect(properties.key?('encrypted_token_iv')).to be_falsy
      end
    end
  end

  xdescribe '#down' do
    before do
      table(:services).create!(type: 'CampfireService', properties: properties_with_encrypted_token )
      table(:services).create!(type: 'CampfireService', properties: properties_with_just_token )
      table(:services).create!(type: 'OtherType', properties: properties_with_encrypted_token )
    end

    it 'removes the encryption attributes if they exit', :aggregate_failures do
      migration.down

      services.where(type: 'CampfireService').all.each do |service|
        properties = Gitlab::Json.parse(service.properties)

        expect(properties.fetch('token')).not_to eq(nil)
        expect(properties.key?('encrypted_token')).to be_falsy
        expect(properties.key?('encrypted_token_iv')).to be_falsy
      end
    end

    it 'does not touch services of other types', :aggregate_failures do
      migration.down

      services.where.not(type: 'CampfireService').all.each do |service|
        properties = Gitlab::Json.parse(service.properties)

        expect(properties.key?('encrypted_token')).to be_truthy
        expect(properties.key?('encrypted_token_iv')).to be_truthy
      end
    end
  end
end
