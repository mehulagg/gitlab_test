# frozen_string_literal: true

require 'spec_helper'

describe Epics::DescendantWeightService do
  describe '#opened_issues' do
    it_behaves_like 'descendants total', :opened_issues, 10
  end

  describe '#closed_issues' do
    it_behaves_like 'descendants total', :closed_issues, 14
  end
end
