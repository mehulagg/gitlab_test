# frozen_string_literal: true

require 'spec_helper'

describe Epics::DescendantCountService do
  describe '#opened_epics' do
    it_behaves_like 'descendants total', :opened_epics, 1
  end

  describe '#closed_epics' do
    it_behaves_like 'descendants total', :closed_epics, 1
  end

  describe '#opened_issues' do
    it_behaves_like 'descendants total', :opened_issues, 2
  end

  describe '#closed_issues' do
    it_behaves_like 'descendants total', :closed_issues, 2
  end
end
