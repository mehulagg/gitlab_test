# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::CreateService do
  let(:current_user) { create(:admin) }
  let(:params) do
    {
      name: 'John Doe',
      username: 'jduser',
      email: 'jd@example.com',
      password: 'mydummypass'
    }
  end

  subject(:service) { described_class.new(current_user, params) }

  describe '#execute' do
    let(:operation) { service.execute }

    context 'audit events' do
      include_examples 'audit event logging' do
        let(:fail_condition!) do
          expect_any_instance_of(User)
            .to receive(:save).and_return(false)
        end

        let(:attributes) do
          {
            author_id: current_user.id,
            entity_id: @resource.id,
            entity_type: 'User',
            details: {
              add: 'user',
              author_name: current_user.name,
              target_id: @resource.full_path,
              target_type: 'User',
              target_details: @resource.full_path
            }
          }
        end
      end

      context 'when audit is not required' do
        let(:current_user) { nil }

        it 'does not log any audit event' do
          expect { operation }.not_to change(AuditEvent, :count)
        end
      end
    end
  end

  context 'active user count threshold' do
    before do
      allow(Gitlab).to receive(:ee?).and_return(true)
    end

    it 'removes all users callouts with feature name ACTIVE_USER_COUNT_THRESHOLD' do
      expect { operation }.to change(UserCallout, :count).to(0)
    end

    context 'when threshold reached' do
      it 'sends email to admin' do
      end
    end
  end
end
