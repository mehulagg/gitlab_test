# frozen_string_literal: true

require 'spec_helper'

describe Analytics::ValueStreamAnalytics::GroupStage do
  describe 'associations' do
    it { is_expected.to belong_to(:group) }
  end

  it_behaves_like 'value stream analytics stage' do
    let(:parent) { create(:group) }
    let(:parent_name) { :group }
  end

  include_examples 'value stream analytics label based stage' do
    let_it_be(:parent) { create(:group) }
    let_it_be(:parent_in_subgroup) { create(:group, parent: parent) }
    let_it_be(:group_label) { create(:group_label, group: parent) }
    let_it_be(:parent_outside_of_group_label_scope) { create(:group) }
  end

  context 'relative positioning' do
    it_behaves_like 'a class that supports relative positioning' do
      let(:parent) { create(:group) }
      let(:factory) { :value_stream_analytics_group_stage }
      let(:default_params) { { group: parent } }
    end
  end
end
