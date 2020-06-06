# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::EventStore do
  let(:store) { described_class.instance }

  let(:event_klass) { stub_const('TestEvent', Class.new(described_class::Event)) }
  let(:event) { event_klass.new(data: data) }

  let(:another_event_klass) { stub_const('TestAnotherEvent', Class.new(described_class::Event)) }

  let(:worker) { double(:worker, perform_async: nil) }
  let(:another_worker) { double(:another_worker, perform_async: nil) }

  before do
    store.reset!
  end

  describe '#subscribe' do
    it 'subscribes a worker to an event' do
      store.subscribe worker, to: event_klass

      subscriptions = store.subscriptions[event_klass]
      expect(subscriptions.map(&:worker)).to contain_exactly(worker)
    end

    it 'subscribes multiple workers to an event' do
      store.subscribe worker, to: event_klass
      store.subscribe another_worker, to: event_klass

      subscriptions = store.subscriptions[event_klass]
      expect(subscriptions.map(&:worker)).to contain_exactly(worker, another_worker)
    end

    it 'subscribes a worker to multiple events is separate calls' do
      store.subscribe worker, to: event_klass
      store.subscribe worker, to: another_event_klass

      subscriptions = store.subscriptions[event_klass]
      expect(subscriptions.map(&:worker)).to contain_exactly(worker)

      subscriptions = store.subscriptions[another_event_klass]
      expect(subscriptions.map(&:worker)).to contain_exactly(worker)
    end

    it 'subscribes a worker to multiple events in a single call' do
      store.subscribe worker, to: [event_klass, another_event_klass]

      subscriptions = store.subscriptions[event_klass]
      expect(subscriptions.map(&:worker)).to contain_exactly(worker)

      subscriptions = store.subscriptions[another_event_klass]
      expect(subscriptions.map(&:worker)).to contain_exactly(worker)
    end

    it 'subscribes a worker to an event with condition' do
      store.subscribe worker, to: event_klass, if: ->(event) { true }

      subscriptions = store.subscriptions[event_klass]

      expect(subscriptions.size).to eq(1)

      subscription = subscriptions.first
      expect(subscription).to be_an_instance_of(described_class::Subscription)
      expect(subscription.worker).to eq(worker)
    end

    it 'refuses the subscription if the target is not an Event object' do
      expect { store.subscribe worker, to: Integer }
        .to raise_error(
          described_class::Error,
          /Event being subscribed to is not a subclass of Gitlab::EventStore::Event/)
    end

    it 'refuses the subscription if the subscriber is not a worker' do
      expect { store.subscribe double, to: event_klass }
        .to raise_error(
          described_class::Error,
          /Subscriber is not an ApplicationWorker/)
    end
  end

  describe '#publish' do
    let(:data) { { name: 'Bob', id: 123 } }

    context 'when event has subscribed workers' do
      before do
        store.subscribe worker, to: event_klass
        store.subscribe another_worker, to: event_klass
      end

      it 'dispatches the event to each subscribed worker' do
        expect(worker).to receive(:perform_async).with('TestEvent', data)
        expect(another_worker).to receive(:perform_async).with('TestEvent', data)

        store.publish(event)
      end

      context 'when an error is raised' do
        before do
          allow(worker).to receive(:perform_async).and_raise(NoMethodError, 'the error message')
        end

        it 'is rescued and tracked' do
          expect(Gitlab::ErrorTracking)
            .to receive(:track_and_raise_for_dev_exception)
            .and_call_original

          expect { store.publish(event) }.to raise_error(NoMethodError, 'the error message')
        end
      end

      it 'refuses publishing if the target is not an Event object' do
        expect { store.publish(double(:event)) }
          .to raise_error(
            described_class::Error,
            /Event being published is not an instance of Gitlab::EventStore::Event/)
      end
    end

    context 'when event has subscribed workers with condition' do
      before do
        store.subscribe worker, to: event_klass, if: -> (event) { event.data[:name] == 'Bob' }
        store.subscribe another_worker, to: event_klass, if: -> (event) { event.data[:name] == 'Alice' }
      end

      let(:event) { event_klass.new(data: data) }

      it 'dispatches the event to the workers satisfying the condition' do
        expect(worker).to receive(:perform_async).with('TestEvent', data)
        expect(another_worker).not_to receive(:perform_async)

        store.publish(event)
      end
    end
  end
end
