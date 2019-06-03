# frozen_string_literal: true

require 'spec_helper'

describe Operations::UnleashFeatureFlag do
  it 'does not allow modification of the operations_feature_flags table' do
    feature_flag = create(:operations_feature_flag, name: 'myflag')
    unleash_feature_flag = described_class.find(feature_flag.id)

    expect { unleash_feature_flag.update(name: 'change') }.to raise_error(ActiveRecord::ReadOnlyRecord)

    feature_flag.reload
    expect(feature_flag.name).to eq('myflag')
  end
end
