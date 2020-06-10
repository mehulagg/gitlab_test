# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'migrate', '20200605114612_change_services_properties_to_jsonb.rb')

describe ChangeServicesPropertiesToJsonb do
  subject(:migration) { described_class.new }

  let(:services) { table(:services) }

  describe '#up' do
    it 'converts the text value to json' do
      services.create!(properties: { foo: 'bar', boolean: true }.to_json)

      migration.up
      services.reset_column_information

      expect(services.first.properties).to eq({ 'boolean' => true, 'foo' => 'bar' })
    end
  end

  describe '#down' do
    it 'converts the json value to text' do
      migrate!
      services.create!(properties: { foo: 'bar', boolean: true })

      migration.down
      services.reset_column_information

      expect(services.first.properties).to eq('{"foo": "bar", "boolean": true}')
    end
  end
end
