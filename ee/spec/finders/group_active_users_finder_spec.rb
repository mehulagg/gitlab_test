# frozen_string_literal: true

require 'spec_helper'

describe GroupActiveUsersFinder do
  subject { described_class.new(group: create(:group)) }

  it 'debugs the sql' do
    subject.execute
  end
end
