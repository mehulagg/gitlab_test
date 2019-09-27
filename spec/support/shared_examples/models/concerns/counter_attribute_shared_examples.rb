# frozen_string_literal: true
require 'spec_helper'

shared_examples_for CounterAttribute do |counter_attributes|
  describe 'Associations' do
    it { is_expected.to have_many(:counter_events).class_name(counter_attribute_events_class.name) }
  end

  it 'captures the model for accessing the events' do
    expect(ProjectStatistics.counter_attribute_events_class).to eq(counter_attribute_events_class)
  end

  it 'captures the table where to save the events' do
    expect(ProjectStatistics.counter_attribute_events_table).to eq(counter_attribute_table_name)
  end

  it 'captures the foreign key to use in the events table' do
    expect(ProjectStatistics.counter_attribute_foreign_key).to eq(counter_attribute_foreign_key)
  end

  it 'captures the counter attributes defined for the model' do
    expect(subject.class.counter_attributes).to contain_exactly(*counter_attributes)
  end

  shared_examples 'logs a new event' do
    it 'in the events table' do
      expect(ConsolidateCountersWorker).to receive(:perform_in).and_return(nil)
      expect { subject.increment_counter!(:build_artifacts_size, 17) }
        .to change { ProjectStatisticsEvent.count }.by(1)

      event = counter_attribute_events_class.last
      expect(event.send(counter_attribute_foreign_key)).to eq(subject.id)
      expect(event.build_artifacts_size).to eq(17)
    end
  end

  counter_attributes.each do |attribute|
    describe attribute do
      describe "#increment_counter!" do
        it_behaves_like 'logs a new event'

        it 'raises ActiveRecord exception if invalid record' do
          expect(ConsolidateCountersWorker).not_to receive(:perform_in)

          expect { subject.increment_counter!(attribute, nil) }
            .to raise_error(ActiveRecord::NotNullViolation)
        end
      end

      describe "#increment_counter" do
        it_behaves_like 'logs a new event'

        it 'logs ActiveRecord errors and returns false' do
          expect(ConsolidateCountersWorker).not_to receive(:perform_in)
          expect(Gitlab::ErrorTracking).to receive(:track_exception).with(anything, {
            model: subject.class.name,
            id: subject.id,
            counter_attribute: attribute,
            increment: nil
          })

          expect(subject.increment_counter(attribute, nil)).to be_falsey
        end

        it 'raises an error if attribute is not a counter attribute' do
          expect(ConsolidateCountersWorker).not_to receive(:perform_in)

          expect { subject.increment_counter(:unknown_attribute, 10) }.to raise_error(CounterAttribute::UnknownAttributeError)
        end
      end

      # TODO: Enable these examples once the update strategy has fully been migrated to use
      # the more efficient CounterAttribute.
      describe "##{attribute}=" do
        xit 'raises an error as setter method is disabled' do
          expect { subject.send("#{attribute}=", 1) }
            .to raise_error(NoMethodError)
            .with_message("Attribute '#{attribute}' is read only")
        end

        xit 'raises an error when updating the attribute using ActiveRecord #update' do
          expect { subject.update(attribute => 1) }
            .to raise_error(NoMethodError)
            .with_message("Attribute '#{attribute}' is read only")
        end
      end

      describe "##{attribute}" do
        before do
          subject.update_column(attribute, 100)
        end

        context 'when there are no pending events' do
          it 'reads the value from the model table' do
            expect(subject.send(attribute)).to eq(100)
          end
        end

        context 'when there are pending events' do
          it 'reads the value from the model table and sums the pending events' do
            expect(ConsolidateCountersWorker).to receive(:perform_in).twice.and_return(nil)
            subject.increment_counter(attribute, 10)
            subject.increment_counter(attribute, -40)

            expect(subject.send(attribute)).to eq(70)
          end
        end
      end
    end
  end
end
