# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::ImportFailureService do
  let(:importable) { create(:project, :builds_enabled, :issues_disabled, name: 'project', path: 'project') }
  let(:label) { create(:label) }
  let(:subject) { described_class.new(importable) }
  let(:relation_key) { "labels" }
  let(:relation_index) { 0 }

  describe '#log_import_failure' do
    let(:standard_error_message) { "StandardError message" }
    let(:exception) { StandardError.new(standard_error_message) }
    let(:correlation_id) { 'my-correlation-id' }

    before do
      # Import is running from the rake task, `correlation_id` is not assigned
      expect(Labkit::Correlation::CorrelationId).to receive(:new_id).and_return(correlation_id)
    end

    context 'when retry_count is 0' do
      let(:log_import_failure) do
        subject.log_import_failure(relation_key, relation_index, exception)
      end

      it 'tracks error' do
        extra = { project_id: importable.id, relation_key: relation_key, relation_index: relation_index }

        expect(Gitlab::ErrorTracking).to receive(:track_exception).with(exception, extra)

        log_import_failure
      end

      it 'saves data to ImportFailure' do
        log_import_failure

        import_failure = ImportFailure.last

        expect(import_failure.relation_key).to eq(relation_key)
        expect(import_failure.relation_index).to eq(relation_index)
        expect(import_failure.exception_class).to eq('StandardError')
        expect(import_failure.exception_message).to eq(standard_error_message)
        expect(import_failure.correlation_id_value).to eq('my-correlation-id')
        expect(import_failure.retry_count).to eq(0)
        expect(import_failure.retry_status).to eq('not_triggered')
        expect(import_failure.created_at).to be_present
      end
    end

    context 'when retry_count is greater then 0' do
      let(:retry_count) { 3 }
      let(:retry_status) { ImportFailure.retry_statuses[:failed] }
      let(:retry_status_key) { 'failed' }
      let(:log_import_failure) do
        subject.log_import_failure(relation_key, relation_index, exception, retry_count, retry_status)
      end

      it 'tracks error' do
        extra = { project_id: importable.id,
                  relation_key: relation_key,
                  relation_index: relation_index,
                  retry_count: retry_count,
                  retry_status: retry_status_key }

        expect(Gitlab::ErrorTracking).to receive(:track_exception).with(exception, extra)

        subject.log_import_failure(relation_key, relation_index, exception, retry_count, retry_status)
      end

      it 'saves data to ImportFailure' do
        log_import_failure

        import_failure = ImportFailure.last

        expect(import_failure.relation_key).to eq(relation_key)
        expect(import_failure.relation_index).to eq(relation_index)
        expect(import_failure.exception_class).to eq('StandardError')
        expect(import_failure.exception_message).to eq(standard_error_message)
        expect(import_failure.correlation_id_value).to eq('my-correlation-id')
        expect(import_failure.retry_count).to eq(retry_count)
        expect(import_failure.retry_status).to eq(retry_status_key)
        expect(import_failure.created_at).to be_present
      end
    end
  end

  describe '#with_retry' do
    let(:perform_retry) do
      subject.with_retry(relation_key, relation_index) do
        label.save!
      end
    end

    where(:exception) do
      [
        ActiveRecord::StatementInvalid,
        GRPC::DeadlineExceeded
      ]
    end

    with_them do
      context "when #{params[:exception]} is raised" do
        context 'when retry succeed' do
          before do
            response_values = [:raise, true]

            allow(label).to receive(:save!).exactly(2).times do
              value = response_values.shift
              value == :raise ? raise(exception) : value
            end
          end

          it 'retries 1 times' do
            expect(label).to receive(:save!).exactly(2).times

            perform_retry
          end

          it 'log import failure with correct params' do
            retry_status = ImportFailure.retry_statuses[:success]

            expect(subject).to receive(:log_import_failure).with(relation_key, relation_index, instance_of(exception), 1, retry_status)

            perform_retry
          end
        end

        context 'when retry fails' do
          before do
            allow(label).to receive(:save!).and_raise(exception)
          end

          it 'retries 3 times' do
            expect(label).to receive(:save!).exactly(3).times

            perform_retry
          end

          it 'log import failure with correct params' do
            retry_status = ImportFailure.retry_statuses[:failed]

            expect(subject).to receive(:log_import_failure).with(relation_key, relation_index, instance_of(exception), 3, retry_status)

            perform_retry
          end
        end
      end
    end
  end
end
