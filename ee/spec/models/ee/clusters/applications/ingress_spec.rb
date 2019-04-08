# frozen_string_literal: true

require 'rails_helper'

describe Clusters::Applications::Ingress do
  describe '#files' do
    let(:application) { create(:clusters_applications_ingress) }
    let(:values) { subject[:'values.yaml'] }

    subject { application.files }

    it 'should include CE and EE specific keys in values' do
      expect(values).to include('image')
      expect(values).to include('config')
      expect(values).to include('enable-modsecurity')
    end
  end
end
