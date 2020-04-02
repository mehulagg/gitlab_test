# frozen_string_literal: true

require 'spec_helper'

describe Projects::CleanupIntegrationsService do
  describe '#execute' do
    context 'emails_on_push_service', :aggregate_failures do
      it 'deletes all matching services' do
        matching_service = create(:emails_on_push_service)
        different_service = create(:emails_on_push_service, recipients: 'different-email@example.com')
        instance_level_service = create(:emails_on_push_service, :instance)

        expect { described_class.new(instance_level_service).execute }.to change { Service.count }.from(3).to(2)
        expect { Service.find(matching_service.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
