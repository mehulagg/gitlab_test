# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require_relative '../../../../rubocop/cop/gitlab/forbid_kernel_open'

describe RuboCop::Cop::Gitlab::ForbidKernelOpen do
  include CopHelper

  subject(:cop) { described_class.new }

  context 'when open method is used' do
    let(:invalid_source) do
      <<~'SRC'
        open("foo")
        open("foo #{bar}")
        open("|foo")
        open("|foo #{bar}")
        open(foo)
        open(nil)
        Kernel.open("foo")
        Kernel.open("foo #{bar}")
        Kernel.open("|foo")
        Kernel.open("|foo #{bar}")
        Kernel.open(foo)
        Kernel.open(nil)
        Kernel.open
      SRC
    end
    let(:valid_source) { 'open' }
    let(:offending_lines) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13] }

    it 'registers an offense when the class includes ForbidKernelOpen' do
      inspect_source(invalid_source)

      aggregate_failures do
        expect(cop.offenses.size).to eq(offending_lines.size)
        expect(cop.offenses.map(&:line)).to eq(offending_lines)
      end
    end

    it 'does not register an offense when the call to open does not have any parameter' do
      inspect_source(valid_source)

      expect(cop.offenses.size).to eq 0
    end
  end
end
