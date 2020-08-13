# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::AlertPresenter do
  let(:project) { build_stubbed(:project) }

  describe '.new' do
    subject { described_class.new(alert) }

    context 'with generic alert' do
      let(:alert) { build_stubbed(:alert_management_alert) }

      it { is_expected.to be_kind_of(AlertManagement::GenericAlertPresenter) }
    end

    context 'with prometheus alert' do
      let(:alert) { build_stubbed(:alert_management_alert, :prometheus) }

      it { is_expected.to be_kind_of(AlertManagement::PrometheusAlertPresenter) }
    end
  end
end
