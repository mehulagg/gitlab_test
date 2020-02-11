# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require_relative '../../../rubocop/cop/filename_length'
require_relative '../../support/helpers/expect_offense'

describe RuboCop::Cop::FilenameLength do
  subject(:cop) { described_class.new }

  it 'does not flag files with names 99 characters long' do
    expect_no_offenses('puts "it does not matter"', "#{Array.new(96, 'a').to_a.join('')}.rb")
  end

  it 'files with names 100 characters long' do
    filename = "#{Array.new(97, 'a').join('')}.rb"
    expect_offense(<<~SOURCE.strip_indent, filename)
    #{filename}
    #{Array.new(99, ' ').join('')}^ The name of this source file `#{filename}` should not exceed 100 characters.
    SOURCE
  end

  it 'files with names 200 characters long' do
    filename = "#{Array.new(197, 'a').join('')}.rb"
    expect_offense(<<~SOURCE.strip_indent, filename)
    #{filename}
    #{Array.new(99, ' ').join('')}#{Array.new(101, '^').join('')} The name of this source file `#{filename}` should not exceed 100 characters.
    SOURCE
  end
end
