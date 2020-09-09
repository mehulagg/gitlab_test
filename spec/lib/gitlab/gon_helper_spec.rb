# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GonHelper do
  let(:helper) do
    Class.new do
      include Gitlab::GonHelper
    end.new
  end

  describe '#push_frontend_feature_flag' do
    it 'pushes a feature flag to the frontend' do
      gon = instance_double('gon')
      thing = stub_feature_flag_gate('thing')

      stub_feature_flags(my_feature_flag: thing)

      allow(helper)
        .to receive(:gon)
        .and_return(gon)

      expect(gon)
        .to receive(:push)
        .with({ features: { 'myFeatureFlag' => true } }, true)

      helper.push_frontend_feature_flag(:my_feature_flag, thing)
    end
  end

  describe '#push_licensed_feature_availability' do
    let(:gon) { instance_double('gon') }

    it 'pushes a licensed feature when parent param is present' do
      parent = double

      expect(parent).to receive(:feature_available?).with(:some_feature).and_return(true)

      allow(helper).to receive(:gon).and_return(gon)

      expect(gon).to receive(:push).with({ features: { 'someFeature' => true } }, true)

      helper.push_licensed_feature_availability(:some_feature, parent)
    end

    it 'pushes a licensed feature when parent param is not present' do
      allow(helper).to receive(:gon).and_return(gon)

      expect(gon).to receive(:push).with({ features: { 'someFeature' => false } }, true)

      helper.push_licensed_feature_availability(:some_feature)
    end
  end

  describe '#default_avatar_url' do
    it 'returns an absolute URL' do
      url = helper.default_avatar_url

      expect(url).to match(/^http/)
      expect(url).to match(/no_avatar.*png$/)
    end
  end
end
