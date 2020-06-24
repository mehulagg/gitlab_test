# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Gitlab::AlertManagement::MappingConfig do
  let(:concise) do
    <<~YAML
      name: prometheus
      fields:
        start_at: startsAt
        title:
          - annotations.title
          - annotations.summary
          - labels.alertname
    YAML
  end

  let(:verbose) do
    <<~YAML
      name: prometheus
      fields:
        start_at:
          type: date
          map_from: startsAt
        title:
          type: string
          map_from:
            - annotations.title
            - annotations.summary
            - labels.alertname
    YAML
  end

  it 'parses concise format' do
    yaml = YAML.load(concise)
    config = described_class.from_yaml(yaml)

    expect(config.name).to eq('prometheus')
    expect(config.fields.size).to eq(2)
    expect(config.fields.map(&:name)).to eq(%w(start_at title))
    expect(config.fields.map(&:type)).to eq(%w(any any))
    expect(config.fields.first.map_from).to eq(%w(startsAt))
    expect(config.fields.last.map_from).to eq(%w(annotations.title annotations.summary labels.alertname))
  end

  it 'parses verbose format' do
    yaml = YAML.load(verbose)
    config = described_class.from_yaml(yaml)

    expect(config.name).to eq('prometheus')
    expect(config.fields.size).to eq(2)
    expect(config.fields.map(&:name)).to eq(%w(start_at title))
    expect(config.fields.map(&:type)).to eq(%w(date string))
    expect(config.fields.first.map_from).to eq(%w(startsAt))
    expect(config.fields.last.map_from).to eq(%w(annotations.title annotations.summary labels.alertname))
  end
end
