# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require_relative '../../../rubocop/cop/package_filename_length_limitations'
require_relative '../../support/helpers/expect_offense'

describe RuboCop::Cop::PackageFilenameLengthLimitations do
  subject(:cop) { described_class.new }

  context 'file name' do
    it 'does not flag files with names 100 characters long' do
      file_path = File.join 'a', 'b' * 100

      expect_no_offenses('puts "it does not matter"', file_path)
    end

    it 'files with names 101 characters long' do
      file_path = File.join 'a', 'b' * 101

      processed_source = RuboCop::ProcessedSource.new('puts "it does not matter"', ruby_version, file_path)
      _investigate(cop, processed_source)
      expect(cop.offenses.size).to be 1
      expect(cop.offenses[0].message).to match /too long name \(should be 100 or less\)$/
    end

    it 'files with names 200 characters long' do
      file_path = File.join 'a', 'b' * 200

      processed_source = RuboCop::ProcessedSource.new('puts "it does not matter"', ruby_version, file_path)
      _investigate(cop, processed_source)
      expect(cop.offenses.size).to be 1
      expect(cop.offenses[0].message).to match /too long name \(should be 100 or less\)$/
    end
  end

  context 'file path prefix' do
    it 'does not flag files with file path prefixes up to 155 characters' do
      file_path = File.join 'a' * 155, 'b'

      expect_no_offenses('puts "it does not matter"', file_path)
    end

    it 'flag files with file path prefixes over 155 characters' do
      file_path = File.join 'a' * 156, 'b'
      processed_source = RuboCop::ProcessedSource.new('puts "it does not matter"', ruby_version, file_path)
      _investigate(cop, processed_source)

      expect(cop.offenses.size).to be 1
      expect(cop.offenses[0].message).to match /too long name \(should be 100 or less\)$/
    end
  end

  context 'absolute length' do
    it 'flag files with file path total length over 256 characters' do
      file_path = File.join 'a' * 257
      processed_source = RuboCop::ProcessedSource.new('puts "it does not matter"', ruby_version, file_path)
      _investigate(cop, processed_source)

      expect(cop.offenses.size).to be 1
      expect(cop.offenses[0].message).to match /has a too long path \(should be 256 or less\)$/
    end
  end
end
