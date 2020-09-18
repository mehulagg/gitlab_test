# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidationWorker do
  let_it_be(:dast_site_validation) { create(:dast_site_validation) }

  subject do
    described_class.new.perform(dast_site_validation.id)
  end

  describe '#perform' do
    context 'when on demand scan feature is disabled' do
      it 'is a noop' do
        stub_licensed_features(security_on_demand_scans: true)
        stub_feature_flags(security_on_demand_scans_site_validation: false)

        expect { subject }.to raise_error(DastSiteValidations::ValidateService::PermissionsError)
      end
    end

    context 'when on demand scan licensed feature is not available' do
      it 'is a noop' do
        stub_licensed_features(security_on_demand_scans: false)
        stub_feature_flags(security_on_demand_scans_site_validation: true)

        expect { subject }.to raise_error(DastSiteValidations::ValidateService::PermissionsError)
      end
    end

    context 'when the feature is enabled' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
        stub_feature_flags(security_on_demand_scans_site_validation: true)
        stub_request(:get, dast_site_validation.validation_url).to_return(body: response_body)
      end

      let(:response_body) do
        dast_site_validation.dast_site_token.token
      end

      it 'validates the url before making an http request' do
        uri = double('uri')

        aggregate_failures do
          expect(Gitlab::UrlBlocker).to receive(:validate!).and_return([uri, nil])
          expect(Gitlab::HTTP).to receive(:get).with(uri).and_return(double('response', body: dast_site_validation.dast_site_token.token))
        end

        subject
      end

      context 'when the request body contains the token' do
        include_examples 'an idempotent worker' do
          subject do
            perform_multiple([dast_site_validation.id], worker: described_class.new)
          end

          it 'marks validation started' do
            Timecop.freeze do
              subject

              expect(dast_site_validation.reload.validation_started_at).to eq(Time.now.utc)
            end
          end

          it 'marks the validation successful' do
            Timecop.freeze do
              subject

              expect(dast_site_validation.reload.validation_passed_at).to eq(Time.now.utc)
            end
          end

          it 'does not updated validation start if already started' do
            subject

            expect { subject }.not_to change { dast_site_validation.reload.validation_started_at }
          end

          context 'when validation is already complete' do
            let_it_be(:dast_site_validation) { create(:dast_site_validation, validation_passed_at: Time.now.utc) }

            it 'does not re-validate' do
              expect(Gitlab::HTTP).not_to receive(:get)

              subject
            end
          end
        end
      end

      context 'when the request body does not contain the token' do
        let(:response_body) do
          SecureRandom.hex
        end

        it 'raises an exception' do
          expect { subject }.to raise_error(DastSiteValidations::ValidateService::TokenNotFound)
        end
      end

      context 'when validation has already been attempted' do
        let_it_be(:dast_site_validation) { create(:dast_site_validation, validation_started_at: Time.now.utc) }

        it 'marks the validation as a retry' do
          Timecop.freeze do
            subject

            expect(dast_site_validation.reload.validation_last_retried_at).to eq(Time.now.utc)
          end
        end
      end
    end
  end

  describe '.sidekiq_retries_exhausted' do
    it 'calls find with the correct id' do
      job = { 'args' => [dast_site_validation.id], 'jid' => '1' }

      expect(dast_site_validation.class).to receive(:find).with(dast_site_validation.id).and_call_original

      described_class.sidekiq_retries_exhausted_block.call(job)
    end

    it 'marks validation failed' do
      job = { 'args' => [dast_site_validation.id], 'jid' => '1' }

      Timecop.freeze do
        described_class.sidekiq_retries_exhausted_block.call(job)

        expect(dast_site_validation.reload.validation_failed_at).to eq(Time.now.utc)
      end
    end
  end
end
