# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::DependencyList::Dependency do
  let(:dependency_nokogiri) { build(:dependency, :nokogiri, :with_vulnerabilities, :direct) }

  context 'initialize' do
    specify do
      dep = described_class.new(dependency_nokogiri)

      expect(dep.to_hash).to eq({ name: 'nokogiri',
                                  iid: 42,
                                  packager: 'Ruby (Bundler)',
                                  package_manager: 'Ruby (Bundler)',
                                  location: { blob_path: '/some_project/path/package_file.lock', path: 'package_file.lock', top_level: true, ancestors: [] },
                                  version: '1.8.0',
                                  licenses: [],
                                  vulnerabilities: [{ name: 'DDoS', severity: 'high' }, { name: 'XSS vulnerability', severity: 'low' }] })
    end

    it 'has unique vulnerabilities' do
      dependency_nokogiri[:vulnerabilities] << { name: 'problem', severity: 'high' }
      dep = described_class.new(dependency_nokogiri)

      expect(dep.vulnerabilities.to_a.map(&:to_hash)).to eq([{ name: 'DDoS', severity: 'high' },
                                                             { name: 'XSS vulnerability', severity: 'low' },
                                                             { name: 'problem', severity: 'high' }])
    end

    it 'removes vulnerability duplicates' do
      dependency_nokogiri[:vulnerabilities] << { name: 'DDoS', severity: 'high' }
      dep = described_class.new(dependency_nokogiri)

      expect(dep.vulnerabilities.to_a.map(&:to_hash)).to eq([{ name: 'DDoS', severity: 'high' },
                                                             { name: 'XSS vulnerability', severity: 'low' }])
    end
  end

  context 'update dependency' do
    specify do
      dependency_nokogiri[:vulnerabilities] << { name: 'DDoS', severity: 'high' } << { name: 'problem', severity: 'high' }
      dep = described_class.new(dependency_nokogiri)

      expect(dep.vulnerabilities.to_a.map(&:to_hash)).to eq([{ name: 'DDoS', severity: 'high' },
                                                             { name: 'XSS vulnerability', severity: 'low' },
                                                             { name: 'problem', severity: 'high' }])
    end
  end
end
