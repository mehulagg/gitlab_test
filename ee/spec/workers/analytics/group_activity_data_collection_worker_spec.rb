# frozen_string_literal: true

require 'spec_helper'

describe GroupActivityDataCollectionWorker do
  describe "#perform" do
    subject(:worker) { described_class.new }

    set(:group) { create(:group) }

    it do
      worker.perform group.id
    end
  end
end
