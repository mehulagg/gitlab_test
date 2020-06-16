# frozen_string_literal: true
require 'spec_helper'

describe Packages::Composer::VersionParserService do
  let_it_be(:params) { {} }

  describe '#execute' do
    using RSpec::Parameterized::TableSyntax

    subject { described_class.new(tag_name: tagname, branch_name: branchname).execute }

    where(:tagname, :branchname, :expected_version) do
      nil             | 'master'     | 'dev-master'
      nil             | 'my-feature' | 'dev-my-feature'
      nil             | 'v1'         | '1.x-dev'
      nil             | 'v1.x'       | '1.x-dev'
      nil             | 'v1.7.x'     | '1.7.x-dev'
      nil             | 'v1.7'       | '1.7.x-dev'
      nil             | '1.7.x'      | '1.7.x-dev'
      'v1.0.0'        | nil          | '1.0.0'
      'v1.0'          | nil          | '1.0'
      '1.0'           | nil          | '1.0'
      '1.0.2'         | nil          | '1.0.2'
      '1.0.2-beta2'   | nil          | '1.0.2-beta2'
    end

    with_them do
      it { is_expected.to eq expected_version }
    end
  end
end
