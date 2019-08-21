# frozen_string_literal: true

require 'fast_spec_helper'

describe Gitlab::Alerting::AlertPayloadParser do
  describe ".call" do
    subject(:parse) { described_class.call(payload) }

    context "when the payload is blank" do
      let(:payload) { nil }

      it "returns parsed payload with blank attributes" do
        is_expected.to eq(
          OpenStruct.new(
            service: :prometheus,
            metric_id: nil,
            title: nil,
            description: nil,
            annotations: nil,
            starts_at: nil,
            generator_url: nil,
            alert_markdown: nil
          )
        )
      end
    end

    context "when the payload has all supported attributes" do
      let(:starts_at) { Time.now.change(usec: 0) }
      let(:generator_url) { 'http://localhost:9090/graph?g0.expr=vector%281%29&g0.tab=1' }
      let(:payload) do
        {
          'labels' => {
            'gitlab_alert_id' => 503
          },
          'annotations' => {
            'title' => 'annotation title',
            'description' => 'alert description',
            'gitlab_incident_markdown' => '**Alert Markdown**'
          },
          'startsAt' => starts_at.rfc3339,
          'generatorURL' => generator_url
        }
      end

      it "returns parsed payload with the attributes" do
        is_expected.to eq(
          OpenStruct.new(
            service: :prometheus,
            metric_id: 503,
            title: 'annotation title',
            description: 'alert description',
            annotations: {
              'title' => 'annotation title',
              'description' => 'alert description',
              'gitlab_incident_markdown' => '**Alert Markdown**'
            },
            starts_at: starts_at.rfc3339,
            generator_url: generator_url,
            alert_markdown: '**Alert Markdown**'
          )
        )
      end

      context "when annotations title is nil" do
        before do
          payload['annotations']['title'] = nil
        end

        context "when annotations summary exists" do
          before do
            payload['annotations']['summary'] = 'summary title'
          end

          it "gets the title from annotations summary" do
            expect(parse.title).to eq('summary title')
          end
        end

        context "when annotations summary is nil" do
          before do
            payload['annotations']['summary'] = nil
            payload['labels']['alertname'] = 'alert title'
          end

          it "gets the title from labels alertname" do
            expect(parse.title).to eq('alert title')
          end
        end
      end
    end
  end
end
