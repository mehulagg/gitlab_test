# frozen_string_literal: true

require 'spec_helper'

describe StatusPage::PublishIncidentDetailsService do
  let(:storage_client) { instance_double(StatusPage::Storage::S3Client) }
  let(:serializer) { instance_double(StatusPage::IncidentSerializer) }
  let(:issue) { instance_double(Issue) }
  let(:user_notes) { double(:user_notes) }
  let(:incident_id) { 1 }
  let(:key) { StatusPage::Storage.details_path(incident_id) }
  let(:content_json) { { id: incident_id } }
  let(:content) { content_json.to_json }

  let(:service) do
    described_class.new(storage_client: storage_client, serializer: serializer)
  end

  subject(:result) { service.execute(issue, user_notes) }

  describe '#execute' do
    before do
      allow(serializer).to receive(:represent_details).with(issue, user_notes)
        .and_return(content_json)
    end

    context 'when upload succeeds' do
      before do
        allow(storage_client).to receive(:upload_object).with(key, content)
      end

      it 'publishes details as JSON' do
        expect(result).to be_success
        expect(result.payload).to eq(object_key: key)
      end
    end

    context 'when upload fails' do
      let(:bucket) { 'bucket_name' }
      let(:error) { StandardError.new }

      let(:exception) do
        StatusPage::Storage::Error.new(bucket: bucket, error: error)
      end

      before do
        allow(storage_client).to receive(:upload_object).with(key, content)
          .and_raise(exception)
      end

      it 'returns an error' do
        expect(result).to be_error
        expect(result.message).to eq(exception.message)
        expect(result.payload).to eq(error: exception)
      end
    end

    context 'when serialized content is missing id' do
      let(:content_json) { { other_id: incident_id } }

      it 'returns an error' do
        expect(result).to be_error
        expect(result.message).to eq('Missing incident key')
        expect(result.payload).to eq(issue: issue)
      end
    end
  end
end
