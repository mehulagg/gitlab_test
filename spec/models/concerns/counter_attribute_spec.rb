# frozen_string_literal: true

require 'spec_helper'

describe CounterAttribute do
  let(:class_with_counter) { ProjectStatistics }
  let(:project) { create(:project) }
  subject { create(:project_statistics, project: project) }

  describe 'Associations' do
    it { is_expected.to have_many(:counter_events).class_name('ProjectStatisticsEvent') }
  end

  it 'captures the class where to save the events' do
    expect(class_with_counter.events_class).to eq(ProjectStatisticsEvent)
  end

  it 'returns #counter_events_table_name' do
    expect(subject.counter_events_table_name).to eq('project_statistics_events')
  end

  describe 'counter_attribute' do
    %w[shared_runners_seconds].each do |attribute|
      describe attribute do
        describe "#increment_#{attribute}" do
          it 'logs a new event' do
            expect(ConsolidateCountersWorker).to receive(:perform_async).and_return(nil)
            expect { subject.send("increment_#{attribute}", 17) }
              .to change { ProjectStatisticsEvent.count }.by(1)

            event = ProjectStatisticsEvent.last
            expect(event.project_statistics).to eq(subject)
            expect(event.attribute_name).to eq(attribute)
            expect(event.value).to eq(17)
          end
        end

        describe "##{attribute}=" do
          it 'raises an error as setter method is disabled' do
            expect { subject.send("#{attribute}=", 1) }
              .to raise_error(NoMethodError)
              .with_message("Attribute '#{attribute}' is read only")
          end

          it 'raises an error when updating the attribute using ActiveRecord #update' do
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
              expect(ConsolidateCountersWorker).to receive(:perform_async).twice.and_return(nil)
              subject.send("increment_#{attribute}", 10)
              subject.send("increment_#{attribute}", -40)

              expect(subject.send(attribute)).to eq(70)
            end
          end
        end
      end
    end
  end
end
