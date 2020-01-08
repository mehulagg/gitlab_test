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
    let(:retry_count) { 2 }
    let(:log_import_failure) do
      subject.log_import_failure(relation_key, relation_index, exception, retry_count)
    end

    before do
      # Import is running from the rake task, `correlation_id` is not assigned
      allow(Labkit::Correlation::CorrelationId).to receive(:current_or_new_id).and_return(correlation_id)
    end

    context 'when importable is a group' do
      let(:importable) { create(:group) }

      it_behaves_like 'log import failure', :group_id
    end

    context 'when importable is a project' do
      it_behaves_like 'log import failure', :project_id
    end

    context 'when importable is not supported by ImportFailure' do
      let(:importable) { create(:merge_request) }

      it 'raise exception' do
        expect { subject }.to raise_exception(RuntimeError, 'ImportFailure source column: merge_request_id is missing')
      end
    end
  end

  describe '#with_retry' do
    let(:perform_retry) do
      subject.with_retry(relation_key, relation_index) do
        label.save!
      end
    end

    where(:exception) { Gitlab::ImportExport::ImportFailureService::RETRIABLE_EXCEPTIONS }

    with_them do
      context "when #{params[:exception]} is raised" do
        context 'when retry succeeds' do
          before do
            response_values = [:raise, true]

            allow(label).to receive(:save!).exactly(2).times do
              value = response_values.shift
              value == :raise ? raise(exception) : value
            end
          end

          it 'retries 1 time' do
            expect(label).to receive(:save!).exactly(2).times

            perform_retry
          end

          it 'retries and logs import failure once with correct params' do
            expect(subject).to receive(:log_import_failure).with(relation_key, relation_index, instance_of(exception), 1)

            perform_retry
          end
        end

        context 'when retry continues to fail with intermittent errors' do
          let(:maximum_retry_count) do
            Retriable.config.tries
          end

          before do
            allow(label).to receive(:save!).and_raise(exception.new)
          end

          it 'retries the number of times allowed and raise exception', :aggregate_failures do
            expect(label).to receive(:save!).exactly(maximum_retry_count).times

            expect { perform_retry }.to raise_exception(exception)
          end

          it 'logs import failure each time and raise exception', :aggregate_failures do
            expect(label).to receive(:save!).exactly(maximum_retry_count).times
            maximum_retry_count.times do |index|
              retry_count = index + 1

              expect(subject).to receive(:log_import_failure).with(relation_key, relation_index, instance_of(exception), retry_count)
            end

            expect { perform_retry }.to raise_exception(exception)
          end
        end
      end
    end
  end
end
